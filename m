Received: from mail-pj2-f7.google.com (mail-pj2-f7.google.com [74.125.227.135])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD09F3BF695
	for <containers@lists.linux.dev>; Sat,  8 Aug 2026 13:23:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.135
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786195398; cv=none; b=imYUQrUIRFblps9QA7/wqNs6RN1QVr7O9BRDgv3QS5ox2Lxq3nqtTntHV3CBm8tR7J5hCmiPrcuKLMm4Y8Z5/MfDdSNQsIvRW58gj8AmESwcC0vXEzw5hONZL+S726JXAePEheKAGKGGONmeaKiqORU9rxHWyfgk7HytRLzfZbY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786195398; c=relaxed/simple;
	bh=r/qwnNRvpRuRUGmnujDseEOKtVd/4UKE65cNO8sZQDQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=ZwQdRkfOr5gx3luJdZJ0xJeuTdb3wFpBVYa9dwCHoyBrNJbLPQy9th4C0aCsDVXJ9wN0xmcwv9C22KarHy54zJdlaMQmrpDHtdLk6mSXROBxp6Ho5iT4+PNxjzCGedYMCbxcYppx8Yx4PjW/4id1IAHLphYa0/Nb/pb2hR1TWcE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ABuWzIhn; arc=none smtp.client-ip=74.125.227.135
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ABuWzIhn"
Received: by mail-pj2-f7.google.com with SMTP id 98e67ed59e1d1-38dcd98e5easo282676a91.0
        for <containers@lists.linux.dev>; Sat, 08 Aug 2026 06:23:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786195396; x=1786800196; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=+sknT3Bnd1z/bdO/Te85NKEmZKwHC4jbouDq5lsiEnQ=;
        b=ABuWzIhn/bksIX+MpweAZ5tdM+bffvdS3EaxT8RjhWLC2ENNZIONwC7o9Es/l5ymMi
         nyayRx/lrmtwMHGXU3QXF1E8NWI7V7JEWSYo5FDxJWvRqee9RbhGC09zh0TvOK1eJGYq
         kYwiTJWcrNjR1GOS61c3txnU0T3JDtWEHJXGs78i0IKMQ4a7oYrgh3C4g3CbbCLSmy8A
         I2BgvKgZvJbmHVVjHMSmGjXgWbe/ga/2ZmyQO6725AzXDVB4F5WQY/Hdb73EwNIeBn+B
         znoDj6jrPRLMSqEp4ajmaTNZXxA0M3ImQjlpsaEs5fz4NO9cydjHreg3sYNRwkfkT9hn
         3QzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786195396; x=1786800196;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=+sknT3Bnd1z/bdO/Te85NKEmZKwHC4jbouDq5lsiEnQ=;
        b=TsXvF7hOWbgH3KCrsUQYB/jKaBQemZHmBtKEZtoAuFHYBetWZ1ybqd+dZ8Vazu1upb
         2X8MW1j0oa94tdJINZ0UH4L9ay/fBkh4af27FC86bu+CPlCJTU37iTK9BIdjKfy5zHsM
         n5ug1aps7O7ULl86vIxtuOEzk7M1F8f5GIsyMCtjgIK0IWrOneVA5vu+Ktk71kMkYehr
         MlOMna59cEKNgNg8mUdYjFSqBH7I2SszXjC77CLkT4upCkchPEPXacHwdzXFStjzKVRS
         08wJVzW7iSVbZaCf3usuSV2qpSxrj3E0Bq/DDasKMlpJ6DEH1AwDJu87I87MShkNLWNq
         +b3A==
X-Forwarded-Encrypted: i=1; AHgh+Ro8UW4W3nJPnhPl3jRMBZCWFi0jSJyjoIqKwDsV/3i0wA5DMSKBqod9j8TOGEeDIJ/UYMNyb4bfy9d3@lists.linux.dev
X-Gm-Message-State: AOJu0YxpedC6qNVrLb7ozkHyxsDd0dgzIk1bgUUGj/UBn1suJ4vFT1hV
	sx4IxXdmWyTUkyRKbMCFv4c6wX75BSKYmhhOFUrWN1X/nnwXezw+eNrb
X-Gm-Gg: AR+sD12IQeGEv1tMnsC1QeSRTt4gkjkPRajvnwhLyHVe8N286YWpY2R3Z9ze60foO3d
	Smuysq0Pfb7Wnfcqe8oxXxwLpjXV9KJxrRLS7SEFmlpNO0MYIVOjfurJh5n3D1PJlqjuFaInAfi
	zDCqh/sNmKk31EkJc1kL/ML5loviZTXuy9wJgo0eRk7a+oDDfQIM3P6+Sm12pHxmUuEVx3FVxcB
	+9IGS5V2xi0MUa42TxE0RViaV5fgg/C6eBpU46tYcICYgcAVWV7lWEIlDhrr4/xH4wa/8clDT6d
	4yU/6PGIP3x5U88wxM/+EClz9Sn+BRjpVD9Moy4Tl/vVfA47XR4HHheKKOS/5rID7nHGqer3WKz
	k+gWgMsHOgJF1ql6Fm90Ott1kjyLhAt0e3+zg9sYJTjdWdGHe80S6ShaD40iEgzDFeUg22maOhH
	KAWhW0yUduSVOT9jSW7fEnlMda+peTeAfjIRIeOJa0vIIKQuWP636kb1LHT3YselD+jgbxvIkpl
	/jhAl0ke4l6eU+B/w==
X-Received: by 2002:a17:90b:2dc1:b0:38f:de97:b06 with SMTP id 98e67ed59e1d1-3903c535d79mr34761030a91.5.1786195396004;
        Sat, 08 Aug 2026 06:23:16 -0700 (PDT)
Received: from xiaomip5p-elish-armbian.. ([2408:8220:6b4b:bb0:6a24:98cc:3eee:6983])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-39085dbe349sm8681959a91.4.2026.08.08.06.23.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 08 Aug 2026 06:23:15 -0700 (PDT)
From: GuLingguang <liu83783@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux.dev,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Aleksa Sarai <cyphar@cyphar.com>,
	Alexey Gladkov <legion@kernel.org>,
	"Serge E . Hallyn" <serge@hallyn.com>,
	GuLingguang <liu83783@gmail.com>
Subject: [RFC] mnt_already_visible(): should regular-file mountpoints participate in the visibility check?
Date: Sat,  8 Aug 2026 21:23:09 +0800
Message-ID: <20260808132309.35924-1-liu83783@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi all,

I have a question about the child-mount check in mnt_already_visible()
in fs/namespace.c, and I would like to understand the intended
invariant before proposing anything.

Background

The check considers an existing proc mount "not fully visible" when
it has a locked child mount whose mountpoint is not a permanently
empty directory:

        list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
                struct inode *inode = child->mnt_mountpoint->d_inode;
                /* Only worry about locked mounts */
                if (!(child->mnt.mnt_flags & MNT_LOCKED))
                        continue;
                /* Is the directory permanently empty? */
                if (!is_empty_dir_inode(inode))
                        goto next;
        }

is_empty_dir_inode() returns false for regular files, so a locked
file mount under /proc (e.g. /proc/uptime) makes the whole proc mount
"not fully visible", and mounting a fresh proc instance inside a user
namespace is rejected with EPERM:

        bwrap: Can't mount proc on /newroot/proc: Operation not permitted

Real-world impact

This affects established workloads:

 * lxcfs (since 2014) overmounts /proc/meminfo and /proc/uptime with
   FUSE files; lxc reported in March 2016 that this blocked running
   an unprivileged container inside a privileged one
   (LKML: "user namespace and fully visible proc and sys mounts").
 * systemd-nspawn can mask paths under /proc (via --inaccessible=,
   overmounting them with inaccessible placeholder nodes);
   flatpak/bwrap inside the container then fails with the EPERM
   above (systemd issue #34226, still open).
 * droidspaces virtualizes /proc/uptime and /proc/loadavg the same
   way today.
 * Kubernetes works around mount_too_revealing() by mounting proc
   from an empty pid namespace (noted in the 2025 procfs pidns API
   series, merge 46582a15c174).

The invariant

The check's stated purpose, in Eric Biederman's own words
(commit 7236c85e1be5), is that fresh mounts of proc and sysfs must
give the mounter:

        "no more access to proc and sysfs than if they could have
         by creating a bind mount"

The original commit (e51db73532955) phrased it as verifying that
"the mounted filesystem is not covered in any significant way".

For a regular-file mountpoint, does a fresh proc mount violate this
invariant?  It seems not, on three counts:

 1. Content.  The only thing a fresh mount reveals beyond the covered
    file is the kernel-generated value of that file, which is already
    reachable through other means -- e.g. the real uptime is available
    from /proc/stat's btime and from the uptime(2) syscall, which are
    not affected by the overmount.  No new information becomes
    accessible.

 2. Structure.  A file mountpoint never covers a directory tree, so
    the directory hierarchy of the fresh mount matches what a bind
    mount of the existing proc would show.

 3. Permissions.  The files themselves remain subject to their own
    permission checks; a fresh mount does not bypass them.
    (One theoretical caveat: an overmount could in principle replace
    a proc file with a bind of a less permissive file (e.g. mode
    0600), which a fresh mount would undo, potentially giving
    non-root users in the namespace access they did not have before.
    I am not aware of any real deployment doing this -- the overmounts
    I know of virtualize read-only values such as uptime/loadavg/
    meminfo with unchanged permissions -- but I would like the
    maintainers' view on whether this caveat is a concern.)

Directory mountpoints are a different matter: a locked directory
mount can hide an entire subtree (hidepid-style masking), which is
what the check is designed to catch.  The question is whether file
mountpoints belong in the same determination.

Historical record

The behaviour for file mountpoints has been unchanged since the check
was introduced in 2013 (rejected then, rejected now), and I could not
find any record -- commit message, mailing list discussion, or code
comment -- in which file mountpoints were discussed.  For example,
the commit message of the 2015 rewrite (7236c85e1be5) speaks only of
directories.  If the rejection of file mountpoints is intentional,
could you point to where that intention was recorded?

Related upstream work

The check was relaxed earlier this year for restricted proc variants
(subset=pid) on the grounds that "almost all container
implementations override part of procfs to hide certain directories"
(merge a76640171b29, April 2026), and the 2016 LKML thread already
discussed the same problem, ending with a userspace workaround rather
than a kernel change.

Questions

 1. Should regular-file mountpoints participate in the "not fully
    visible" determination at all?
 2. Is the invariant the check protects about the presence/type of
    mounts on proc, or about the visibility of procfs's directory
    tree?
 3. Is there a recorded intent for rejecting file mountpoints, and
    does it still apply given the above?

I am deliberately not proposing an implementation yet; I would like
to understand the intended invariant first.

Thanks,
GuLingguang <liu83783@gmail.com>
