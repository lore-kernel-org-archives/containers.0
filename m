From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 00/18] userns: review of bug fixes for 3.19-rcX
Date: Fri, 12 Dec 2014 16:32:16 -0600
Message-ID: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org


The entire tree for testing is available at:
	git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

This is my queue of important bug fixes for user namespaces.  Most of
these changes warrant being backported.  A few are bug fixes for cases
where only root can trigger the issue so have not been marked for being
back ported to stable.

A few of these patches have not been posted for review preivously, so I
a giving the light of mailling list before I send them to Linus.  This
patchset has seen some testing already. 

Since there are small deliberate breakage of userspace in here the more
reviewers/testers the better.

Baring complictions I intend to ask Linus to pull this patchset sometime
early next week.

So far nothing broke on my libvirt-lxc test bed. :-)
Tested with openSUSE 13.2 and libvirt 1.2.9.
Tested-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>

Tested on Fedora20 with libvirt 1.2.11, works fine.
Tested-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Eric W. Biederman (18):
      mnt: Implicitly add MNT_NODEV on remount when it was implicitly added by mount
      mnt: Update unprivileged remount test
      umount: Disallow unprivileged mount force
      umount: Do not allow unmounting rootfs.
      mnt: Move the clear of MNT_LOCKED from copy_tree to it's callers.
      mnt: Carefully set CL_UNPRIVILEGED in clone_mnt
      mnt: Clear mnt_expire during pivot_root
      groups: Consolidate the setgroups permission checks
      userns: Document what the invariant required for safe unprivileged mappings.
      userns: Don't allow setgroups until a gid mapping has been setablished
      userns: Don't allow unprivileged creation of gid mappings
      userns: Check euid no fsuid when establishing an unprivileged uid mapping
      userns: Only allow the creator of the userns unprivileged mappings
      userns: Rename id_map_mutex to userns_state_mutex
      userns: Add a knob to disable setgroups on a per user namespace basis
      userns: Allow setting gid_maps without privilege when setgroups is disabled
      userns; Correct the comment in map_write
      userns: Unbreak the unprivileged remount tests
