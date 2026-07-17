# ONIE machine revision (part of the recovery image filename).
ONIE_RECOVERY_IMAGE_VER = r0
# GitHub release tag on sonic-ocs/onie holding the recovery ISO asset. Kept
# separate from the machine rev so the ISO can be rebuilt/republished without
# bumping the machine revision. ocs-kvm-r0 is the fresh ONIE 2025.11 port
# (branch ocs-kvm-2025.11, SECURE_BOOT_ENABLE=no + config-insecure kernel) whose
# runtime retains the x86_64-efi grub modules the UEFI KVM install needs.
# ocs-kvm-r1 was the earlier 2018.11-based UEFI-capable rebuild.
ONIE_RECOVERY_RELEASE_TAG = ocs-kvm-r0
ONIE_RECOVERY_IMAGE = onie-recovery-x86_64-ocs-kvm_x86_64-$(ONIE_RECOVERY_IMAGE_VER).iso
$(ONIE_RECOVERY_IMAGE)_URL = "https://github.com/sonic-ocs/onie/releases/download/$(ONIE_RECOVERY_RELEASE_TAG)/$(ONIE_RECOVERY_IMAGE)"

SONIC_ONLINE_FILES += $(ONIE_RECOVERY_IMAGE)
