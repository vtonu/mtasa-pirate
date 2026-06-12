# Script Security (MTA)

## Core Security Principle

**Never trust anything coming from the client.**

Anything stored, executed, or transmitted through the client can be:

- Read
- Modified
- Faked
- Injected
- Replayed

This includes:

- Client-side Lua
- Shared scripts
- Element data
- Event parameters
- Triggered events

Always perform important logic and validation on the server.

---

## Client-Side Data Risks

### Unsafe Locations

Anything located on the player's PC should be considered compromised:

- Client scripts
- Shared scripts
- Variables
- Cached resources
- Event data
- Element data

### Safe Location

Sensitive systems should exist only server-side:

- Admin systems
- Economy logic
- Authentication
- Permissions
- Inventory systems
- Anti-cheat decisions
- Database operations

---

## Shared Scripts

A shared script runs independently on both client and server.

```xml
<script src="script.lua" type="shared"/>
```

Equivalent to:

```xml
<script src="script.lua" type="client"/>
<script src="script.lua" type="server"/>
```

Therefore anything inside a shared file must be treated as exposed to the client.

---

## Protecting Client Scripts

### cache="false"

```xml
<script src="client.lua" type="client" cache="false"/>
```

Prevents scripts from being permanently saved to the player's disk.

Benefits:

- Makes code extraction harder
- Reduces casual inspection
- Hides logic flaws from most users

Limitations:

- Not impossible to bypass
- Does not remove previously downloaded files
- Does not replace proper security

---

## Resource Security

Before using any resource:

### Check meta.xml

Look for:

- Hidden scripts
- Unexpected files
- Suspicious dependencies

### Review Source Code

Check for:

- Backdoors
- ACL abuse
- Hidden admin commands
- Unauthorized database access

### Avoid Unknown Compiled Resources

Never trust compiled scripts unless the source is known and verified.

---

## ACL Security

Use ACL to restrict dangerous functions.

Examples:

- banPlayer
- kickPlayer
- executeCommandHandler
- database administration

Never grant admin rights to unknown resources.

Apply a zero-trust approach.

---

# Event Security

## Golden Rule

### Never Trust Source

Everything received through `triggerServerEvent` can be faked.

Including:

- source
- arguments
- element references
- IDs
- values

### Trust Client

The special server variable:

```lua
client
```

cannot be faked.

Always use:

```lua
client
```

to identify who actually triggered the event.

---

## Wrong Pattern

```lua
hasObjectPermissionTo(source, ...)
```

A cheater may fake source.

---

## Correct Pattern

```lua
hasObjectPermissionTo(client, ...)
```

Always validate permissions using client.

---

## Admin Event Security

Before executing admin actions:

1. Verify client exists
2. Verify ACL membership
3. Verify permissions
4. Validate all incoming data

Example checks:

```lua
isObjectInACLGroup(...)
hasObjectPermissionTo(...)
```

---

## Event Naming

Do not reuse MTA internal event names.

Bad:

```lua
onPlayerLogin
```

for a custom event.

This may create security problems.

Use unique names instead.

Example:

```lua
myServerPlayerLogin
```

---

## triggerClientEvent Security

Never send confidential events to everyone.

Bad:

```lua
triggerClientEvent(root, ...)
```

Good:

```lua
triggerClientEvent(player, ...)
```

or

```lua
triggerClientEvent({player1, player2}, ...)
```

Examples of sensitive data:

- Admin information
- Account information
- Private statistics
- Staff tools

Benefits:

- Better security
- Better performance

---

# Element Data Security

## Avoid Excessive setElementData Usage

Prefer:

```lua
triggerClientEvent()
```

instead of constantly syncing element data.

Reasons:

- Better performance
- Smaller attack surface
- Less synchronization abuse

---

## Sync Control

Use:

```lua
setElementData(..., false)
```

to disable synchronization when possible.

Benefits:

- Data isn't automatically exposed to clients
- Harder to inspect

However:

- Not a complete security solution
- Server validation is still required

---

## Protect Element Data

When clients can modify data:

Validate:

- Who changed it
- Which element received it
- Value type
- Value length
- Allowed range

Examples:

### Player-only Data

Allow data only on:

```lua
client == source
```

### Vehicle-only Data

Allow data only on:

```lua
getPedOccupiedVehicle(client)
```

---

## Recommended Data Validation

For each protected key define:

### Allowed Element Types

Examples:

- player
- vehicle
- ped
- object

### Allowed Data Types

Examples:

- string
- number
- boolean
- table

### Length Restrictions

Examples:

- String length 1-32
- Table size 1-64

### Range Restrictions

Examples:

- Number 1-100

---

## Element Data Anti-Cheat

Monitor:

```lua
onElementDataChange
```

When suspicious changes occur:

1. Log the incident
2. Revert the change
3. Remove invalid keys
4. Optionally kick or ban

---

# Event Data Validation

Every server event should validate:

### Source

Ensure:

```lua
source == client
```

when appropriate.

### Element Types

Validate received elements.

Example:

```lua
player
vehicle
ped
object
```

### Data Types

Validate:

```lua
string
number
boolean
table
```

### String Length

Prevent:

- Spam
- Buffer abuse
- Large payloads

### Number Range

Prevent:

- Invalid IDs
- Economy exploits
- Overflow values

### Table Length

Prevent:

- Memory abuse
- Network abuse
- Massive payload attacks

---

# Recommended Security Checklist

### Client Side

- Assume all client data is compromised
- Keep sensitive logic server-side
- Use cache="false" where useful

### Resources

- Audit resources before use
- Avoid unknown compiled scripts
- Keep resources updated

### ACL

- Restrict dangerous functions
- Never blindly trust resources

### Events

- Never trust source
- Always trust client
- Validate every parameter
- Verify ACL permissions for admin actions
- Use unique custom event names

### Element Data

- Use sparingly
- Prefer triggerClientEvent
- Validate changes
- Restrict keys, types, lengths, and ranges
- Monitor onElementDataChange

### Anti-Cheat

- Log suspicious activity
- Revert malicious changes
- Kick or ban when appropriate

---

## Most Important Rule

**All parameters (including source) can be faked and should not be trusted.**

**The global server variable `client` can be trusted and should be used for security validation.**
