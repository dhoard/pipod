#!/usr/bin/env bats
# Unit tests for host_timezone: the IANA zone name passed to `docker run` as TZ.
# `readlink` is shadowed by a function so /etc/localtime can be faked.

load test_helper

@test "explicit TZ wins" {
    TZ=America/Chicago
    readlink() { echo /usr/share/zoneinfo/Europe/Berlin; }
    [ "$(host_timezone)" = "America/Chicago" ]
}

@test "leading colon in TZ is stripped" {
    TZ=:Asia/Tokyo
    [ "$(host_timezone)" = "Asia/Tokyo" ]
}

@test "TZ that is a file path falls back to /etc/localtime" {
    TZ=:/etc/localtime
    readlink() { echo /usr/share/zoneinfo/Europe/Berlin; }
    [ "$(host_timezone)" = "Europe/Berlin" ]
}

@test "unset TZ: zone name from the /etc/localtime symlink" {
    unset TZ
    readlink() { echo ../usr/share/zoneinfo/America/New_York; }
    [ "$(host_timezone)" = "America/New_York" ]
}

@test "macOS-style /etc/localtime target" {
    unset TZ
    readlink() { echo /var/db/timezone/zoneinfo/Europe/Kyiv; }
    [ "$(host_timezone)" = "Europe/Kyiv" ]
}
