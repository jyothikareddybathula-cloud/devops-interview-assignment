#!/usr/bin/env python3

import argparse
import json
import sys
import xml.etree.ElementTree as ET


def parse_args():
    parser = argparse.ArgumentParser(description="ONVIF Camera Discovery Tool")
    parser.add_argument(
        "--input",
        help="Path to XML file (default: stdin)",
        default=None
    )
    parser.add_argument(
        "--timeout",
        help="Discovery timeout in seconds",
        type=int,
        default=5
    )
    return parser.parse_args()


def parse_onvif_response(xml_content):
    cameras = []

    namespaces = {
        "soap": "http://www.w3.org/2003/05/soap-envelope",
        "wsd": "http://schemas.xmlsoap.org/ws/2005/04/discovery",
        "dn": "http://www.onvif.org/ver10/network/wsdl",
        "tds": "http://www.onvif.org/ver10/device/wsdl"
    }

    try:
        root = ET.fromstring(xml_content)

        for match in root.findall(".//wsd:ProbeMatch", namespaces):
            xaddr = match.find("wsd:XAddrs", namespaces)
            endpoint = match.find("wsd:EndpointReference/wsd:Address", namespaces)

            service_url = xaddr.text if xaddr is not None else None
            uuid = endpoint.text if endpoint is not None else None

            if service_url:
                ip = service_url.split("/")[2].split(":")[0]
            else:
                ip = None

            camera = {
                "uuid": uuid,
                "model": None,
                "name": None,
                "location": None,
                "service_url": service_url,
                "ip": ip
            }

            cameras.append(camera)

        return cameras

    except ET.ParseError:
        return []


def main():
    args = parse_args()

    try:
        if args.input:
            with open(args.input, "r") as f:
                xml_content = f.read()
        else:
            xml_content = sys.stdin.read()

        cameras = parse_onvif_response(xml_content)

        print(json.dumps(cameras, indent=2))

    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()
