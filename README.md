# CommandedJson

This is a test project to show potential problems in [commanded](https://github.com/commanded/commanded) with the jsonb data type together with the [Commanded.Serialization.JsonSerializer](Commanded.Serialization.JsonSerializer).

If you use `Commanded.Serialization.JsonSerializer` together with the [jsonb data type](https://github.com/commanded/eventstore/blob/master/guides/Getting%20Started.md#using-the-jsonb-data-type) your data (and metadata) will still be saved as a string.

## The Problem

When wanting to serialize your event data to json there are two possible serializer you can use:

`Commanded.Serialization.JsonSerializer`: shipped with [commanded](https://github.com/commanded/commanded) and [default serializer](https://github.com/commanded/commanded/blob/master/guides/Serialization.md#default-json-serializer). This serializer is independent of the configured event store. If you however are using it together with Postgres you will not be able to configure the [Postgres JSON functions](https://www.postgresql.org/docs/9.4/functions-json.html) on your event store, even if you configure `data` and `metadata` columns to be [jsonb](https://github.com/commanded/eventstore/blob/master/guides/Getting%20Started.md#using-the-jsonb-data-type).

`EventStore.JsonbSerializer`: shipped with [eventstore]((https://github.com/commanded/eventstore)) and specifically useful for storing event data as jsonb. Downside is: it doesn't support the [decoding events functionality](https://github.com/commanded/commanded/blob/master/guides/Serialization.md#decoding-event-structs). So if you want to convert strings into atoms or use elixir date types, this serializer will get in the way of that.

## Solution

This project fulfills a variety of use cases related to that:

- It lets you reproduce the behavior described above (see [Usage](#usage) for details)
- It provides you with a [serializer])(lib/commanded_json/serializer.ex) that handles both cases (storing in jsonb and decoding on deserialization)
- It has example code to migrate an existing string events over to proper json storage

## Usage

- Install dependencies: `mix deps.get`
- Initialize the event store: `mix do event_store.create, event_store.init`
- Run `mix make_it_happen` to persist two events
- Run `mix look_what_happened` to read persisted event and print them on the terminal

You can pass in the parameter `raw` to show the pure event data without deserialization: `mix look_what_happened raw`

## New Serializer

The serializer of this project acts as a dispatcher between `Commanded.Serialization.JsonSerializer` and `EventStore.JsonbSerializer`. It serializes all data to proper jsonb on inserting new events and calls the decoding functionality on deserialization.

Furthermore when having a mix of string and jsonb in your database the deserialization will automatically recognize the format and will call the appropriate serializer.

## Migrate Existing Event Store

**CAUTION: This procedure goes against the principles of event sourcing and might break compliance protocols of your organization. You should be very careful when changing the data of your event store.**

Even though you can switch your serializer after events have already been persisted, there might be good reasons to backfill the existing events.

To convert all events with a string data or metadata field run the following mix task:


```shell
mix migrate_events 
```
