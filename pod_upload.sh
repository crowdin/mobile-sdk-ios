#!/bin/bash

git checkout .

git checkout master

pod trunk me

pod trunk push --allow-warnings --skip-tests