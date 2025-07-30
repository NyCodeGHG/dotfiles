#!/usr/bin/env python3
import netifaces
import ipaddress
import cloudflare
import os
import pathlib

token_file = os.getenv("CLOUDFLARE_TOKEN_FILE")
token = pathlib.Path(token_file).read_text(encoding='utf8').strip()
client = cloudflare.Client(api_token=token)

interfaces = netifaces.interfaces()
addresses = []

for iface in interfaces:
    iface_addresses = netifaces.ifaddresses(iface)
    if netifaces.AF_INET6 not in iface_addresses:
        continue
    for address in iface_addresses[netifaces.AF_INET6]:
        ip_addr = ipaddress.IPv6Address(address["addr"])
        if ip_addr.is_global:
            addresses.append(ip_addr)
            print(f"Got address: {ip_addr.compressed}")

zone_id = os.getenv("CLOUDFLARE_ZONE_ID")
if zone_id is None:
    raise Exception("Missing CLOUDFLARE_ZONE_ID")

record_name = os.getenv("CLOUDFLARE_RECORD_NAME")
if record_name is None:
    raise Exception("Missing CLOUDFLARE_RECORD_NAME")

records = client.dns.records.list(
    zone_id=zone_id, name={"exact": record_name}, type="AAAA"
)

if len(records.result) == 0:
    # No records found
    for address in addresses:
        print(f"Creating record {record_name}: {address}")
        client.dns.records.create(
            zone_id=zone_id, name=record_name, type="AAAA", content=str(address)
        )
else:
    existing_records = []
    to_be_deleted = []
    for record in records.result:
        address = ipaddress.IPv6Address(record.content)
        if address in addresses:
            existing_records.append(address)
        else:
            to_be_deleted.append(record)

    for address in addresses:
        if address not in existing_records:
            print(f"Creating record {record_name}: {address}")
            client.dns.records.create(
                zone_id=zone_id, name=record_name, type="AAAA", content=str(address)
            )

    for record in to_be_deleted:
        print(f"Deleting record {record.name}: {record.content}")
        client.dns.records.delete(record.id, zone_id=zone_id)
