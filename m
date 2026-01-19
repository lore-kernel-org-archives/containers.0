Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF1BC22F77B
	for <containers@lists.linux.dev>; Mon, 19 Jan 2026 19:01:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768849296; cv=none; b=Wtw027HrRLioBeo0fmCRlWIgnwK6stVBaegtPkyY8h5LSFMhMuCNANsuLRoH+QlisH/SkP3xPEKCGE6ig4P/p2ziv/mx44t4rs21qMy65ckUn+hybanBOs40jqEqsG6JZajIP1le7Z6H7ZONF1le5BAHQteQqJOLNKUjyHd4xyU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768849296; c=relaxed/simple;
	bh=bI5IPQFJ+by3IIQyhZwdLpvLyRBSEgqkFjkzhjf0OBQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HIfd5dvwGdXBKBzzSmzmZWsayaV4XYNfspkBcQ2m6krbv99A8Bq7Y2DQSRWornfoRONdRAQ02tzQu+eNlYwF9h/HT/ci2I0C8OMXIGStV6Xs+umRuoQ2gG+zTkVA+l7+82yTR7XH8XsZib+44Olla3ONXu/cQwqfDoJtIbpkqHY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=MfvHH4Bi; arc=none smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MfvHH4Bi"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-64b58553449so8191870a12.1
        for <containers@lists.linux.dev>; Mon, 19 Jan 2026 11:01:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1768849293; x=1769454093; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=ihXpfk6s5RJismx/mSJFIyW5r33kfZuDg7he69hJB7c=;
        b=MfvHH4BiPSxaB4TkLXcD1ZGJDFyBbbCMlUUnl/dU2b5zh/dDeM+ouldolF4pLkAgBP
         quxHOc1MtSsYKHnXEvtkYd5Tg6kNA7kJx+3dy2aN2Hsv7tzI6vuaBvmk47RCajBlsr7q
         AE8+Hw+ciz284Cz30izGHEobh2Liq+OAPEqVeXAwdVMqCdzMmdTjbSoJEkKUPDuWPh8K
         M0nQK8RGVQdkypdX9Q/lX7SzRyE/y0JsctrwRy3ClI7UYtF8VJ1U8pRlPXFQnDbGWZg0
         2R5uc18lRy3FlaoLOf3L/fd9fiQk9fmo9I96zIk7+zsqHpvqTfvDjZ1a5MOh+BkKH1Qn
         u3ew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1768849293; x=1769454093;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=ihXpfk6s5RJismx/mSJFIyW5r33kfZuDg7he69hJB7c=;
        b=Y39JWT37+QQHJCRDyphDEpYR5ZshTvUkfCxzb5G0eZ1OhdJqGHbaugewxnAgX5O47M
         iDFH/ansKWM/kihI4haQJ8XnkB7SoNlvC1QKJhXFIQkZEvcBYG2XJw5oFgE1T/ssPQLJ
         +HawlhhfM2IC6Kx8246ua/6ugI3bitPBu8S2zFwOhsWEGZZBW59CSzIPiNe/fvfP2ljs
         Cnw3bOzMt+1Ubxn5N4Q8FNjOUXGnI5O4NY+63YjGa97lE7HtvIidyiKXngt1rqAY6GPd
         uwwYmcXILwBD4x33TT8WhRLvmTWjkJn4c5sywQCbI38la5fodt5Arh85PBTbB+equ7Xp
         ++dg==
X-Forwarded-Encrypted: i=1; AJvYcCVtqwwP1r5qRPAmDIMbiSbCGFRxg3O5Uf2F4kbn/HoV/7tuQ4DFGr6FL1hS7kX9kw+kvrFuKhVfYNPc@lists.linux.dev
X-Gm-Message-State: AOJu0YwmdSdRVNQ7vpTpE3E/KNNRi+VeS/ac95RwrBOmtYY7eDGEgbpm
	FhPup8K0dWGasBd36BCT2j391JxeSoX2nxG5MsAMAgLTcy5HHwfvMEMrmtZ1oQ==
X-Gm-Gg: AY/fxX7S/GzazxtdCj1hJqi075Bhb5GgrpB+WHVBBQGznksDdXcxJkHfTYJ49jY13Tq
	YTRFWJV2UP7Pjx6ksS3LzsuElGCV8HitLdlHjUSirl3eTP2Vhu/rx6fe+Um+dEsNNzMs3OiWgj0
	BWTdE6WR54XM/XFr5IVw/ghiCE2aQ1UiPSb//3s93Ds3iEO28yl/8QbNBtS1EtWHfgyLiHYsSL6
	swgz6ySfUaE/bnVTzTqXoT5xB3uQBK2+aa/a4do5YYTePeIvjYHvelsCYKc+vtOVGpudetflvIL
	kJBfII5ckkT+LJ2CKNp8MlvwtlUyDHsNehOs8D/HqFjmjZ9TyxT+TKhx/UC5mbL9YvPjh174CeL
	Pad8yaR0B8ag3Mn8oe82XQsUws/OEI+JhY+heFWcBVHrWO/kNgq4G7Lw4VfcGYvE+Za1Vx9oIHv
	WognqOhyNyjsqvb0rGDw==
X-Received: by 2002:a05:6000:613:b0:432:586f:2ab9 with SMTP id ffacd0b85a97d-435699787cdmr17106815f8f.5.1768842854026;
        Mon, 19 Jan 2026 09:14:14 -0800 (PST)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id ffacd0b85a97d-43569922032sm25380858f8f.8.2026.01.19.09.14.11
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 19 Jan 2026 09:14:13 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: brauner@kernel.org
Cc: amir73il@gmail.com,
	cyphar@cyphar.com,
	jack@suse.cz,
	jlayton@kernel.org,
	josef@toxicpanda.com,
	linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk,
	Lennart Poettering <mzxreary@0pointer.de>,
	David Howells <dhowells@redhat.com>,
	Zhang Yunkai <zhang.yunkai@zte.com.cn>,
	cgel.zte@gmail.com,
	Menglong Dong <menglong8.dong@gmail.com>,
	linux-kernel@vger.kernel.org,
	initramfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-api@vger.kernel.org,
	news@phoronix.com,
	lwn@lwn.net,
	Jonathan Corbet <corbet@lwn.net>,
	Rob Landley <rob@landley.net>,
	emily@redcoat.dev,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 0/2] mount: add OPEN_TREE_NAMESPACE
Date: Mon, 19 Jan 2026 20:11:01 +0300
Message-ID: <20260119171101.3215697-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org>
References: <20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Christian Brauner <brauner@kernel.org>:
> Extend open_tree() with a new OPEN_TREE_NAMESPACE flag. Similar to
> OPEN_TREE_CLONE only the indicated mount tree is copied. Instead of
> returning a file descriptor referring to that mount tree
> OPEN_TREE_NAMESPACE will cause open_tree() to return a file descriptor
> to a new mount namespace. In that new mount namespace the copied mount
> tree has been mounted on top of a copy of the real rootfs.

I want to point at security benefits of this.

[[ TL;DR: [1] and [2] are very big changes to how mount namespaces work.
I like them, and I think they should get wider exposure. ]]

If this patchset ([1]) and [2] both land (they are both in "next" now and
likely will be submitted to mainline soon) and "nullfs_rootfs" is passed on
command line, then mount namespace created by open_tree(OPEN_TREE_NAMESPACE) will
usually contain exactly 2 mounts: nullfs and whatever was passed to
open_tree(OPEN_TREE_NAMESPACE).

This means that even if attacker somehow is able to unmount its root and
get access to underlying mounts, then the only underlying thing they will
get is nullfs.

Also this means that other mounts are not only hidden in new namespace, they
are fully absent. This prevents attacks discussed here: [3], [4].

Also this means that (assuming we have both [1] and [2] and "nullfs_rootfs"
is passed), there is no anymore hidden writable mount shared by all containers,
potentially available to attackers. This is concern raised in [5]:

> You want rootfs to be a NULLFS instead of ramfs. You don't seem to want it to
> actually _be_ a filesystem. Even with your "fix", containers could communicate
> with each _other_ through it if it becomes accessible. If a container can get
> access to an empty initramfs and write into it, it can ask/answer the question
> "Are there any other containers on this machine running stux24" and then coordinate.

Note: as well as I understand all actual security bugs are already fixed in kernel,
runc and similar tools. But still [1] and [2] reduce chances of similar bugs
in the future, and this is very good thing.

Also: [1] and [2] are pretty big changes to how mount namespaces work, so
I added more people and lists to CC.

This mail is answer to [1].

[1] https://lore.kernel.org/all/20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org/
[2] https://lore.kernel.org/all/20260112-work-immutable-rootfs-v2-0-88dd1c34a204@kernel.org/

[3] https://lore.kernel.org/all/rxh6knvencwjajhgvdgzmrkwmyxwotu3itqyreun3h2pmaujhr@snhuqoq44kkf/
[4] https://github.com/opencontainers/runc/pull/1962
[5] https://lore.kernel.org/all/cec90924-e7ec-377c-fb02-e0f25ab9db73@landley.net/

-- 
Askar Safin
