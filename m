Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D85E5274658
	for <containers@lists.linux.dev>; Sat, 26 Sep 2026 07:00:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790406059; cv=none; b=ZDBp6QYWIr9QDoYRPocsR1o7ln+LPUockf9p+2c1Xau4HRFZCZZjGbk3NMWUM5Vvseo1/MEwjuKyBelrB8ZkJrTgElKc+K6AUEPJNrS94txnmp4ppnZmhIcQQSzVgmJHakc/2PF/rFpeKmxIywzcmqvzi9ZUnaM6vNAPdIt6lrQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790406059; c=relaxed/simple;
	bh=zYwQwewCk4P7+4enRD40+cZRarhYq0yRswb+8KrgcNk=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=p3oDu9dwXYy31HVuiCAMoppyeWJ7Yny1cdmVfDDX8T1trZOfvut6/8SKjdZs8xQTOOU7E2MSjUHgBRytb7ZH7YigFsJzEWZweSuDn3BMQUeWGMpEZA51am6apVNX6o8QBGS4hCAevqWpGSO7OifgHA/70zvrkUbVlf+CMfyT1R0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=DgDIdDGZ; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DgDIdDGZ"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2d8fdc579daso10549575ad.1
        for <containers@lists.linux.dev>; Sat, 26 Sep 2026 00:00:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790406057; x=1791010857; darn=lists.linux.dev;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=lFMzbROQnPZ03LFhgGCTeVYFQX7f/d2hoEAIuqyzaxg=;
        b=DgDIdDGZ/APFikZCVt9gGA0+PW119LLh6gyKLnacNEJtC6dYXH6S4csc6o1Q7qYmwf
         BkOI2obRWy8O0PmQ+kaw89nyDTV1p0/DRydTXOT7ef+ca14iW3MK5QQytGezx14zseW0
         AjQ7bpkwwEvY3vZCv91ROjOdL0p5wcDE1UyYjnKNYDF2wiafyEw06GkHVneAnyb3IhRx
         evbAhxnHDYycVBbskxseL3hKykCdM7uuwVyUwJ/CSsBAvuUM8DRfrAv8jOx6lQv9Q3Xe
         6f80xoiT6tcR2bpE2Aj+o/frlszNMLGdhvhMmuvqjPsykxrRziV0WR/g4WnfkOPWXPnw
         i0Vg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790406057; x=1791010857;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=lFMzbROQnPZ03LFhgGCTeVYFQX7f/d2hoEAIuqyzaxg=;
        b=cMdFjUiELyqkDzhpsyW5d9WUQ5n4GGpaqtCJRf4c1+cuSDhk284RfpNYWsqmFG+1f1
         uWObi1fPToh8noV9s14XCGuHAuArgdM+Fnqtl2cnPSgk445NWLDCNyE0b6lksrR+z4an
         icM5BHTOMjTPEzPPElktu5Shkj4kOPNOoAkWuk4hOmokq+LUtQCYMRffw1lv7wOUyNdf
         wv7LPvAF6yyVF/HkWaDl5ZSeXEnR24SftZ6HQi/jfup9qe4SORBihCpNlK6OAvG0qrub
         GOjp36rG46laeJ7T/zeF0lTKZ/V41rq6KGHAbkUN3XPRr724Gc9lMWtQPD8zhvwztRfn
         FBcA==
X-Forwarded-Encrypted: i=1; AKwUvBy05KiW4nQ2FAh+45lqYxI7S+6/lIefgLNsTmD8/UBD9IBhDW4uku3zhVH664ph+lJHKubZ/18TlIgT@lists.linux.dev
X-Gm-Message-State: AFq9FYKDUk+ES4AWhn2/xKLpbYXMeaIlcql4TsrcWKvAm3sAVTnge7VK
	sbwjaajlL7U4kYgWPwXVLm2GKzZs8BGfKblEnFj3J5ehG1oA1Cc5e857
X-Gm-Gg: AYBFou0p5jqjO0YpTH9EHiIg0zm4TWgk6wjs45Ga+K+7GJbv/nfH6XzhrTGHZ1a2ygu
	7WQRnf7AXgpeRsQc/eeZ8HLoVYBzwtcbsdq8Bqn4qmumZgyx8OMie/FcrViCCEfh4O9JBaRGPU5
	9Hfq2g4wv5EPYMMiV3DgywdmGE9Cb4KwHeV/+4U1xnfLAmiZjQA4JmtQLqEStuh19wrf6Esvxlx
	cDPE2W3gmecCDPxK/HXx+Sxxa+N+TUtd2i2CKz6tW+hjt4OL02CsRstFhyIweYphq5G5xdKqr02
	gn/dSH2tRrGa8e6OTzv4SOwp/nRs2eXyVXvZA4dPindTBzgY+Nurh0fxTREtbXOyae3ieMXvY0h
	Hq87OJhzqSmpK8xbQgjQZy8s0ENOHHOXILRFit38Hl6ovZgnBuG/Az+5Q8lIhhO8qc1WqUhzp2O
	2l8qLm3xjDAhyBBINfuVRagAVYh7iLO8nr8KhqMNe8bRZFpXzRwbSCra0kiFf6x01SKY1ZnQ==
X-Received: by 2002:a17:90b:1b08:b0:39d:e213:9dd3 with SMTP id 98e67ed59e1d1-3a098d4769emr6127977a91.1.1790406057113;
        Sat, 26 Sep 2026 00:00:57 -0700 (PDT)
Received: from [10.1.2.130] ([67.185.120.12])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0974ec5d0sm15987119a91.4.2026.09.26.00.00.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 00:00:56 -0700 (PDT)
From: Kir Kolyshkin <kolyshkin@gmail.com>
Subject: [PATCH v2 0/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
Date: Sat, 26 Sep 2026 00:00:52 -0700
Message-Id: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MMQqAMAxA0atIZgMlUEu9ijhoTTVLlQRFEO9uc
 XzD/w8Yq7BB3zygfInJXiqobSBtU1kZZakGctS5SB6LZcNDz8KoOSHPlHwI0c+JoEaHcpb7Hw7
 j+352CNG5YAAAAA==
X-Change-ID: 20260925-nsfs-prune-rfc-eb2c57795bc2
To: Christian Brauner <brauner@kernel.org>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Aleksa Sarai <cyphar@cyphar.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
 "Eric W . Biederman" <ebiederm@xmission.com>, 
 David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, 
 Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
 Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 containers@lists.linux.dev, Kir Kolyshkin <kolyshkin@gmail.com>
X-Mailer: b4 0.14.3

crun, a container runtime, recently started using OPEN_TREE_NAMESPACE to
set up the container's mount namespace, and open_tree(OPEN_TREE_CLONE)
for the sources of its bind mounts.  This turns out not to work on hosts
that have a mount namespace pinned anywhere below such a source: the
recursive clone picks the pinned namespace up, and move_mount(2) then
refuses to attach the tree with ELOOP from check_for_nsfs_mounts().

The rule behind that goes back to commit 8823c079ba71 ("vfs: Add setns
support for the mount namespace"), which requires "all bind mounts be of
a younger mount namespace into an older mount namespace" so that mount
namespace reference loops cannot form.  OPEN_TREE_NAMESPACE ends up on
the wrong side of it by construction: the namespace it creates is younger
than everything else on the system, so from inside it every pinned
namespace is older.

By the time this fails there is nothing userspace can do.  setns() has
already run, so the host tree is unreachable by path; it is unreachable
through a fd saved beforehand as well, since mount(2) requires the source
to live in the current mount namespace; and the offending mounts cannot
be dropped from the detached copy first, because umount(2) requires
check_mnt().  So a runtime cannot fall back to the pivot_root() path at
that point -- it has to predict the situation before setns(), which is
what crun now does, at the cost of the optimization on every such host.

This is not a corner case: snapd pins mount namespaces under
/run/snapd/ns, so on Ubuntu it affects any container that bind mounts the
host root, which is not uncommon [2].

Every other path that crosses a mount namespace boundary already leaves
these mounts behind: copy_mnt_ns() passes CL_COPY_UNBINDABLE | CL_EXPIRE,
and create_new_namespace() passes no CL_COPY_MNT_NS_FILE either -- the
latter deliberately, per the comment added in commit 9b8a0ba68246
("mount: add OPEN_TREE_NAMESPACE"): "When creating a new mount namespace
we don't want to copy over mounts of mount namespaces to avoid the risk
of cycles".  Only get_detached_copy() asks for them, inherited from the
unconditional CL_COPY_MNT_NS_FILE that predates that exception.

Patch 1 adds a flag so a caller can ask for a clone without them, as
suggested by Aleksa when the exception was introduced [1]:

    I kind of think this is a somewhat theoretical issue but I don't
    think we'll be bitten by it. My gut feeling is that I'd prefer this
    to be an OPEN_TREE_* flag that you have to set (so we can support
    this in the future) but that's kinda ugly too...

Keep it opt-in rather than changing the default.  A clone attached in the
caller's own namespace, or in an older one, keeps such mounts usable, and
open_tree(OPEN_TREE_CLONE) plus move_mount(2) is what mount --rbind is
through a file descriptor, so dropping them by default would make
mount --rbind / /mnt silently lose /run/snapd/ns/*.mnt on a live system.
Only a caller heading into a younger namespace, where the tree is refused
anyway, has reason to ask for this.

With OPEN_TREE_NAMESPACE, which never copies these mounts, the flag is
accepted and has no effect, so a runtime can pass it unconditionally.
Locked nsfs mounts are skipped the same way copy_mnt_ns() already skips
them, so this exposes nothing new.

Containers observe no difference: set up the traditional way, with
unshare(CLONE_NEWNS) and pivot_root(), they see no nsfs mounts under a
recursive bind of the host root today.

Tested by booting the patched kernel in qemu and running the selftests in
tools/testing/selftests/filesystems/open_tree_ns: 19 pass (including
the two new cases), 12 skip (all in the existing tests), none fail.
Without the flag, move_mount() fails exactly as described, with ELOOP.

Patch 2 adds the selftests.

Changes since v1:
 - split into the kernel change and the selftest (Christian)
 - rename OPEN_TREE_SKIP_MNTNS to OPEN_TREE_DROP_MNTNS_MOUNTS (Christian)
 - shorten the commit message

v1: https://lore.kernel.org/linux-fsdevel/20260923205028.711077-1-kolyshkin@gmail.com/

[1] https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spills-ywC2O3@cyphar.com/
[2] https://github.com/containers/crun/issues/2262

Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
---
Kir Kolyshkin (2):
      mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
      selftests/filesystems: test OPEN_TREE_DROP_MNTNS_MOUNTS

 fs/namespace.c                                     |  14 +-
 include/uapi/linux/mount.h                         |   1 +
 .../filesystems/open_tree_ns/open_tree_ns_test.c   | 183 +++++++++++++++++++++
 3 files changed, 196 insertions(+), 2 deletions(-)
---
base-commit: b5a051f6b840d48f159166ef073d3021989bfb50
change-id: 20260925-nsfs-prune-rfc-eb2c57795bc2

Best regards,
-- 
Kir Kolyshkin <kolyshkin@gmail.com>

