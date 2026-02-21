#!/usr/bin/env python3

import argparse
import logging
import sys
import time


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )


def health_check(environment, timeout=300):
    logging.info(f"Running health check for {environment} environment...")
    time.sleep(2)
    logging.info("Application is healthy.")
    return True


def deploy(environment, image_tag, dry_run=False):
    logging.info(f"Starting deployment to {environment}")
    logging.info(f"Image tag: {image_tag}")

    if dry_run:
        logging.info("Dry run enabled — no changes applied.")
        return

    logging.info("Deploying application...")
    time.sleep(2)

    if not health_check(environment):
        logging.error("Health check failed. Rolling back...")
        rollback(environment)
        sys.exit(1)

    logging.info("Deployment successful.")


def rollback(environment, revision=None):
    logging.info(f"Rolling back deployment in {environment}")
    if revision:
        logging.info(f"Rolling back to revision {revision}")
    else:
        logging.info("Rolling back to previous revision")
    time.sleep(2)
    logging.info("Rollback completed.")


def status(environment):
    logging.info(f"Checking deployment status for {environment}")
    logging.info("Application is running and healthy.")


def parse_args():
    parser = argparse.ArgumentParser(description="Deployment automation tool")

    subparsers = parser.add_subparsers(dest="command")

    deploy_parser = subparsers.add_parser("deploy")
    deploy_parser.add_argument("--environment", required=True, choices=["staging", "production"])
    deploy_parser.add_argument("--image-tag", required=True)
    deploy_parser.add_argument("--dry-run", action="store_true")
