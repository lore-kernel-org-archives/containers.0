From: <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: patch sysfs-implement-sysfs_delete_link-and-sysfs_rename_link.patch
	added to gregkh-2.6 tree
Date: Fri, 20 Jul 2007 23:36:23 -0700
Message-ID: <20070721063655.975FF14458DB@imap.suse.de>
References: <m1vech2e6o.fsf_-_@ebiederm.dsl.xmission.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1vech2e6o.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org


This is a note to let you know that I've just added the patch titled

     Subject: [PATCH 3/4] sysfs: Implement sysfs_delete_link and sysfs_rename_link

to my gregkh-2.6 tree.  Its filename is

     sysfs-implement-sysfs_delete_link-and-sysfs_rename_link.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


From ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org  Fri Jul 20 23:21:06 2007
From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Wed, 18 Jul 2007 22:46:39 -0600
Subject: [PATCH 3/4] sysfs: Implement sysfs_delete_link and sysfs_rename_link
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Message-ID: <m1vech2e6o.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>



When removing a symlink sysfs_remove_link does not provide enough
information to figure out which shadow directory the symlink falls in.
So I need sysfs_delete_link which is passed the target of the symlink
to delete.

Further half the time when we are removing a symlink the code is
actually renaming the symlink but not doing so explicitly because we
don't have a symlink rename method.  So I have added sysfs_rename_link
as well.

Both of these functions now have enough information to find a symlink
in a shadow directory.  The only restriction is that they must be
called before the target kobject is renamed or deleted.  If they are
called later I loose track of which tag the target kobject was marked
with and can no longer find the old symlink to remove it.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 fs/sysfs/symlink.c    |   31 +++++++++++++++++++++++++++++++
 include/linux/sysfs.h |   18 ++++++++++++++++++
 2 files changed, 49 insertions(+)

--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -126,6 +126,21 @@ addrm_finish:
 
 
 /**
+ *	sysfs_delete_link - remove symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@name:	name of the symlink to remove.
+ *
+ *	Unlike sysfs_remove_link sysfs_delete_link has enough information
+ *	to successfully delete symlinks in shadow directories.
+ */
+void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
+			const char *name)
+{
+	sysfs_hash_and_remove(targ, kobj->sd, name);
+}
+
+/**
  *	sysfs_remove_link - remove symlink in object's directory.
  *	@kobj:	object we're acting for.
  *	@name:	name of the symlink to remove.
@@ -136,6 +151,22 @@ void sysfs_remove_link(struct kobject * 
 	sysfs_hash_and_remove(kobj, kobj->sd, name);
 }
 
+/**
+ *	sysfs_rename_link - rename symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@old:	previous name of the symlink.
+ *	@new:	new name of the symlink.
+ *
+ *	A helper function for the common rename symlink idiom.
+ */
+int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
+			const char *old, const char *new)
+{
+	sysfs_delete_link(kobj, targ, old);
+	return sysfs_create_link(kobj, targ, new);
+}
+
 static int sysfs_get_target_path(struct sysfs_dirent * parent_sd,
 				 struct sysfs_dirent * target_sd, char *path)
 {
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -127,6 +127,13 @@ sysfs_create_link(struct kobject * kobj,
 extern void
 sysfs_remove_link(struct kobject *, const char * name);
 
+extern int
+sysfs_rename_link(struct kobject *kobj, struct kobject *target,
+			const char *old_name, const char *new_name);
+
+extern void
+sysfs_delete_link(struct kobject *dir, struct kobject *targ, const char *name);
+
 int __must_check sysfs_create_bin_file(struct kobject *kobj,
 					struct bin_attribute *attr);
 void sysfs_remove_bin_file(struct kobject *kobj, struct bin_attribute *attr);
@@ -202,6 +209,17 @@ static inline void sysfs_remove_link(str
 	;
 }
 
+static inline int
+sysfs_rename_link(struct kobject * k, struct kobject *t,
+			const char *old_name, const char * new_name)
+{
+	return 0;
+}
+
+static inline void
+sysfs_delete_link(struct kobject *k, struct kobject *t, const char *name)
+{
+}
 
 static inline int sysfs_create_bin_file(struct kobject * k, struct bin_attribute * a)
 {


Patches currently in gregkh-2.6 which might be from greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org are

bad/pci-domain/pci-device-ensure-sysdata-initialised.patch
bad/pci-domain/pci-fix-the-x86-pci-domain-support-fix.patch
bad/relayfs/sysfs-update-relay-file-support-for-generic-relay-api.patch
bad/relayfs/relay-consolidate-relayfs-core-into-kernel-relay.c.patch
bad/relayfs/relay-relay-header-cleanup.patch
bad/relayfs/relayfs-remove-relayfs-in-favour-of-config_relay.patch
bad/relayfs/sysfs-add-__attr_relay-helper-for-relay-attributes.patch
bad/relayfs/sysfs-relay-channel-buffers-as-sysfs-attributes.patch
bad/usbip/usb-usbip-more-dead-code-fix.patch
bad/usbip/usb-usbip-build-fix.patch
bad/usbip/usb-usbip-warning-fixes.patch
bad/ndevfs.patch
bad/battery-class-driver.patch
bad/driver-model-convert-driver-model-to-mutexes.patch
bad/gpl_future-test.patch
bad/gregkh-debugfs_example.patch
bad/speakup-kconfig-fix.patch
bad/speakup-build-fix.patch
bad/pci-use-new-multi-phase-suspend-infrastructure.patch
bad/shot-accross-the-bow.patch
bad/no-more-non-gpl-modules.patch
bad/spi-device.patch
bad/ata_piix-multithread.patch
bad/uio-irq.patch
bad/pci-two-drivers-on-one-pci-device.patch
bad/pci-dynamic-id-cleanup.patch
bad/input-device.patch
bad/usb-stimulus.patch
driver/nozomi.patch
driver/kobject-put-kobject_actions-in-kobject.h.patch
driver/sysfs-implement-sysfs-manged-shadow-directory-support.patch
driver/sysfs-implement-sysfs_delete_link-and-sysfs_rename_link.patch
driver/sysfs-remove-first-pass-at-shadow-directory-support.patch
driver/driver-core-implement-shadow-directory-support-for-device-classes.patch
gregkh/gkh-version.patch
gregkh/sysfs-test.patch
gregkh/sysrq-u-laptop.patch
pci/pci_bridge-device.patch
pci/pci-piggy-bus.patch
pci/pci-move-prototypes-for-pci_bus_find_capability-to-include-linux-pci.h.patch
pci/pci-document-pci_iomap.patch
usb/usb-gotemp.patch
usb/kobject-put-kobject_actions-in-kobject.h.patch
usb/usb-add-the-concept-of-default-authorization-to-usb-hosts.patch
usb/usb-cleanup-usb_register_bus-and-hook-up-sysfs-group.patch
usb/usb-initialize-authorization-and-wusb-bits-in-usb-devices.patch
usb/usb-introduce-usb_device-authorization-bits.patch
usb/usb-usb_set_configuration-obeys-authorization.patch
usb/usb-usb.h-kernel-doc-additions.patch
HOWTO
