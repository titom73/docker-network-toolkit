#!/usr/bin/env python
# coding: utf-8

from setuptools import setup, find_packages

setup(
    name="snmptrap-receiver",
    version="1.0.0",
    description="A simple SNMP trap receiver for demo and lab purposes",
    author="Thomas Grimonet",
    author_email="tom@inetsix.net",
    url="https://github.com/titom73/docker-snmptrap-receiver",
    license="Apache-2.0",
    python_requires=">=3.8",
    install_requires=[
        "pysnmp>=4.4.12",
    ],
    scripts=["bin/snmptrap-receiver"],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: System :: Networking :: Monitoring",
    ],
)

