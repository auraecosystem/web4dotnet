

---

## 1️⃣ ADD A NEW SECCOMP/APPARMOR POLICY

**Location:** `security/Policy` (currently a stub)

**Pattern:** Create individual policy files per security domain.

```bash
# Create a new Seccomp profile
touch security/seccomp_custom.json

# Create a new AppArmor profile
touch security/apparmor_custom.profile
```

**Example: `security/seccomp_custom.json`**
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "defaultErrnoRet": 1,
  "archMap": [
    {
      "architecture": "SCMP_ARCH_X86_64",
      "subArchitectures": ["SCMP_ARCH_X86", "SCMP_ARCH_X32"]
    }
  ],
  "syscalls": [
    {
      "names": ["read", "write", "open", "close", "stat"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["ptrace", "process_vm_readv"],
      "action": "SCMP_ACT_LOG"
    }
  ]
}
```

**Example: `security/apparmor_custom.profile`**
```.profile
#include <tunables/global>

profile aura-custom flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  # Allow container reads/writes
  /var/lib/aura-moby/** rw,
  
  # Restrict capability set
  deny capability sys_admin,
  allow capability net_bind_service,
  
  # Network rules
  network inet dgram,
  network inet stream,
}
```

**Wire it into Go code:**
```go
// engine/security.go (new file)
package engine

import (
	"encoding/json"
	"io/ioutil"
)

func LoadSeccompPolicy(path string) (map[string]interface{}, error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var policy map[string]interface{}
	if err := json.Unmarshal(data, &policy); err != nil {
		return nil, err
	}
	return policy, nil
}
```

**Update `CLAUDE.md`:**
```markdown
# Security Policy Management
- Load Seccomp: `engine.LoadSeccompPolicy("security/seccomp_custom.json")`
- Verify AppArmor syntax: `sudo apparmor_parser -d security/apparmor_custom.profile`
```

---

## 2️⃣ ADD A NEW AI SCHEDULER ROUTINE

**Location:** `ai/scheduler/` (currently a stub)

**Pattern:** Create a new scheduler module with telemetry hooks.

```bash
touch ai/scheduler/scheduler.go
touch ai/scheduler/predictor.go
```

**Example: `ai/scheduler/scheduler.go`**
```go
package scheduler

import (
	"context"
	"time"
)

type SchedulerConfig struct {
	TensorLoadRatio float64       // Threshold for triggering optimization
	CheckInterval   time.Duration // How often to probe metrics
}

type Scheduler struct {
	config SchedulerConfig
}

func NewScheduler(cfg SchedulerConfig) *Scheduler {
	return &Scheduler{config: cfg}
}

func (s *Scheduler) PredictContainerBlockage(ctx context.Context, containerID string) (bool, error) {
	// TODO: Query telemetry to predict CPU thread starvation
	// Check ai/telementary/ data
	// Return true if blockage predicted
	return false, nil
}

func (s *Scheduler) Optimize(ctx context.Context, containerID string) error {
	// TODO: Apply SIMD vectorization or thread rebalancing
	// Call into native/bridge.zig for acceleration
	return nil
}
```

**Example: `ai/scheduler/predictor.go`**
```go
package scheduler

import (
	"encoding/json"
)

type TelemetryFrame struct {
	Timestamp     int64   `json:"ts"`
	CPUUsage      float64 `json:"cpu"`
	MemoryUsage   float64 `json:"mem"`
	ThreadCount   int     `json:"threads"`
	TensorOpsRate float64 `json:"tensor_ops_per_sec"`
}

func PredictLoad(frames []TelemetryFrame) float64 {
	if len(frames) == 0 {
		return 0.0
	}
	avg := 0.0
	for _, f := range frames {
		avg += f.TensorOpsRate
	}
	return avg / float64(len(frames))
}
```

**Update `CLAUDE.md`:**
```markdown
# AI Scheduler Development
- Test scheduler: `go test ./ai/scheduler/...`
- Run with custom config: Pass `SchedulerConfig{TensorLoadRatio: 0.8}`
```

**Update `doc/ai.md`** (currently empty stub):
```markdown
# AI Scheduler & Telemetry

The scheduler monitors container workloads via telemetry frames and predicts CPU thread blockages.

## Key Functions
- `PredictContainerBlockage()`: Uses historical tensor ops to forecast starvation
- `Optimize()`: Applies SIMD acceleration via native layer

## Telemetry Metrics
- `tensor_ops_per_sec`: Operations per second (triggers optimization if high)
- `ThreadCount`: Active thread count (blockage if stalled)
```

---

## 3️⃣ ADD SUPPORT FOR A NEW ARCHITECTURE

**Location:** `Makefile`, `build.zig`, and new assembly files

**Pattern:** Add cross-compile targets and architecture-specific native code.

**Step 1: Update `Makefile`**
```wrb4.mk
# Add to existing Makefile
## build-matrix: Cross-compile static C-ABI libraries and Go binaries for AMD64, ARM64, and RISC-V

build-matrix:
	@echo "==> Initiating matrix compilation pipeline..."
	
	@echo "--> Building for Linux AMD64..."
	@mkdir -p $(NATIVE_DIR)/linux_amd64
	zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast --summary failures
	@mv -f zig-out/lib/* $(NATIVE_DIR)/linux_amd64/
	CGO_LDFLAGS="-L$(shell pwd)/$(NATIVE_DIR)/linux_amd64 -laurabridge -static" \
	GOOS=linux GOARCH=amd64 go build -ldflags="-extldflags=-static" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/dev

	@echo "--> Building for Linux ARM64..."
	@mkdir -p $(NATIVE_DIR)/linux_arm64
	zig build -Dtarget=aarch64-linux -Doptimize=ReleaseFast --summary failures
	@mv -f zig-out/lib/* $(NATIVE_DIR)/linux_arm64/
	CGO_LDFLAGS="-L$(shell pwd)/$(NATIVE_DIR)/linux_arm64 -laurabridge -static" \
	CC="zig cc -target aarch64-linux" GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 ./cmd/dev

	# NEW: RISC-V Support
	@echo "--> Building for Linux RISC-V64..."
	@mkdir -p $(NATIVE_DIR)/linux_riscv64
	zig build -Dtarget=riscv64-linux -Doptimize=ReleaseFast --summary failures
	@mv -f zig-out/lib/* $(NATIVE_DIR)/linux_riscv64/
	CGO_LDFLAGS="-L$(shell pwd)/$(NATIVE_DIR)/linux_riscv64 -laurabridge -static" \
	CC="zig cc -target riscv64-linux" GOOS=linux GOARCH=riscv64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-riscv64 ./cmd/dev
	
	@echo "==> Matrix build complete. Artifacts stored in /$(BUILD_DIR)"
```

**Step 2: Create architecture-specific Assembly**
```bash
touch native/riscv64.asm
```

**Example: `native/riscv64.asm`**
```asm
.section .text
.global aura_transform_buffer_abi

# RISC-V64 C-ABI: a0=input, a1=output, a2=length
aura_transform_buffer_abi:
    beq a2, zero, .done_riscv
.loop_riscv:
    lbu t0, 0(a0)           # Load byte from input
    sb t0, 0(a1)            # Store to output
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    bne a2, zero, .loop_riscv
.done_riscv:
    ret
```

**Step 3: Update `build.zig`**
```zig
// Add to build.zig after existing assembly inclusion
lib.addAssemblyFile(b.path("native/riscv64.asm"));
```

**Step 4: Update `docker-compose.yml`** for multi-arch builds:
```yaml
aura-moby-engine:
  build:
    context: .
    dockerfile: Dockerfile
    platforms:
      - "linux/amd64"
      - "linux/arm64"
      - "linux/riscv64"  # NEW
```

**Step 5: Update `Dockerfile`** for conditional builds:
```dockerfile
ARG TARGETARCH

# In builder stage, conditionally set compile flags
RUN if [ "$TARGETARCH" = "riscv64" ]; then \
      CGO_LDFLAGS="-L/native/linux_riscv64 -laurabridge" GOOS=linux GOARCH=riscv64 go build ...; \
    else \
      CGO_LDFLAGS="-L/native/linux_${TARGETARCH}" go build ...; \
    fi
```

**Update `CLAUDE.md`:**
```markdown
# Multi-Architecture Build
- Build all: `make build-matrix`
- Build single: `zig build -Dtarget=riscv64-linux`
- Docker multi-arch: `docker buildx build --platform linux/amd64,linux/arm64,linux/riscv64 .`
```

---

## 4️⃣ ADD DOCUMENTATION

**Location:** `doc/` directory

**Pattern:** Follow the existing structure—each subsystem gets its own markdown file.

**Example: `doc/security.md`** (replace the stub)
```markdown
# Security Architecture

## Overview
Aura Moby enforces defense-in-depth via Seccomp, AppArmor, and SELinux policies.

## Seccomp Profiles
Located in `security/seccomp_*.json`. Profiles restrict system calls at the kernel level.

### Default Profile (`security/seccomp_custom.json`)
- **Allowed calls:** `read`, `write`, `open`, `close`, `mmap`, `mprotect`
- **Blocked calls:** `ptrace`, `process_vm_readv`, `syslog`, `admin` capabilities
- **Logged calls:** Suspicious patterns for forensics

### Loading Profiles
```go
// engine/security.go
policy, err := LoadSeccompPolicy("security/seccomp_custom.json")
```

## AppArmor Rules
Located in `security/apparmor_*.profile`. Enforces mandatory access controls (MAC).

### File Access
```
/var/lib/aura-moby/** rw,        # Container data
/etc/aura-moby/** r,             # Config (read-only)
deny /etc/shadow rwx,            # Never access shadow
```

### Capabilities
```ps1
allow capability net_bind_service,
deny capability sys_admin,
deny capability sys_ptrace,
```

## Testing Security Policies
```bash
# Verify Seccomp JSON
jq . security/seccomp_custom.json

# Load AppArmor profile (requires sudo)
sudo apparmor_parser -d security/apparmor_custom.profile

# Test in container
docker run --security-opt seccomp=security/seccomp_custom.json aura-moby
```
```
```
**Example: `doc/native.md`** (replace the stub)
```markdown
# Native Layer & Assembly Integration

## Architecture & Register Mapping

Aura Moby bridges Go into high-performance Assembly via C-ABI calling conventions.

### Register Layout (System V AMD64)
| Register | Purpose |
|----------|---------|
| `rdi` | Input buffer pointer |
| `rsi` | Output buffer pointer |
| `rdx` | Buffer length |
| `rax` | Return code |

### Register Layout (RISC-V64)
| Register | Purpose |
|----------|---------|
| `a0` | Input buffer pointer |
| `a1` | Output buffer pointer |
| `a2` | Buffer length |
| `a0` | Return code |
```
## C-ABI Contract

```go
// Go signature
func ProcessContainerData(inputSlice []byte) ([]byte, error)

// Assembly entry point
extern fn aura_process_payload(input: [*]const u8, output: [*]u8, len: u64) callconv(.C) i32
```

## Memory Pinning Requirements

**CRITICAL:** Always pin Go memory when passing slices to Assembly.

```go
var pinner runtime.Pinner
pinner.Pin(&inputSlice[0])
defer pinner.Unpin()  // Must unpin before function returns
```

Without pinning, the Go garbage collector can relocate heap memory, corrupting the pointer passed to Assembly.

## Assembly Files

- `native/windows.nasm` — x86-64 (Windows x64 ABI)
- `native/riscv64.asm` — RISC-V 64-bit
- `native/bridge.zig` — Zig C-ABI wrapper

## Compilation

```bash
# Compile with Zig
zig build -Doptimize=ReleaseFast

# Verify generated symbols
nm zig-out/lib/libaurabridge.a | grep aura_
```
```
```
**Example: `doc/ai.md`** (replace the stub)
```markdown
# AI Scheduler & Optimization

## Overview
The AI subsystem predicts container workload bottlenecks and applies runtime optimizations via SIMD vectorization and thread scheduling.

## Scheduler Loop

Located in `ai/scheduler/scheduler.go`.

### Components
1. **Telemetry Collector** (`ai/telementary/`) — Streams CPU/memory metrics
2. **Predictor** (`ai/scheduler/predictor.go`) — Forecasts thread blockages
3. **Optimizer** (`native/`) — Applies low-latency fixes
```
### Prediction Algorithm

```bash
For each telemetry frame:
  tensor_load = (ops_per_sec) / (max_ops_theoretical)
  if tensor_load > threshold (0.8):
    PredictBlockage = true
    TriggerOptimize()
```

### Configuration

```go
scheduler := NewScheduler(SchedulerConfig{
  TensorLoadRatio: 0.8,
  CheckInterval:   time.Second * 5,
})
```

## Testing

```bash
go test ./ai/scheduler/... -v
```
```
```
**Step 6: Update `doc/README.md`** to link to new docs:
```markdown
# Documentation Index

- [Architecture Overview](Architecture.md) — System design
- [Security Policies](security.md) — Seccomp & AppArmor
- [Native Layer](native.md) — Assembly & C-ABI
- [AI Scheduler](ai.md) — Workload prediction
- [Moby Integration](Moby.md) — Container engine
- [Web Interfaces](Paperweb.md) — Admin dashboards
```

**Step 7: Sync docs to GitHub Pages**
```bash
make doc-sync
git add docs/
git commit -m "docs: add security, native, and AI scheduler documentation"
git push origin main
# Automatically builds & deploys to auraecosystem.github.io/aura-moby/
```

---

## Summary Checklist

- ✅ **Security policies:** Create `security/seccomp_*.json` and `security/apparmor_*.profile`
- ✅ **AI scheduler:** Create `ai/scheduler/*.go` with telemetry integration
- ✅ **New architecture:** Add assembly file, update `Makefile` & `build.zig`, add Dockerfile platform
- ✅ **Documentation:** Populate `doc/security.md`, `doc/native.md`, `doc/ai.md`
- ✅ **CLAUDE.md:** Update with new build/test commands
- ✅ **Sync:** Run `make doc-sync` and push to main

