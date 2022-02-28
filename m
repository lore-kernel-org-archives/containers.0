Received: from mail-wr1-f44.google.com (mail-wr1-f44.google.com [209.85.221.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8DEA53A4
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 11:39:26 +0000 (UTC)
Received: by mail-wr1-f44.google.com with SMTP id r10so14976281wrp.3
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 03:39:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=0ctFKY1Dn2SOXBB41lbEysb0dPgkRzW0iBsvqQk91OU=;
        b=cGb9pCH7UGzehVfHvOjm/Xn7p05IpP4lbxAKR6gMNebpfRLPE0PwwnAGZyFaDk/HGB
         sYQvvMzjkx9z97y3tVVToewgpsROikL/YVo0OY7YN0YHtPM7vcNe/8QEhATSzZchsf3W
         FHdFotQxcCKV4qXyAoWUnAUPgm8dMRal519rcQZkgfmM0JsdhC1ocIOz8AxCvj5RoWBS
         c1676/YahJPFJyGDA/h+aH+p+nLKjJDURytvQrZLIIKSzZ2JTiisLKKeaCHzHDi+6Djx
         RO5I468fdtpOdK8omzgbsD4qZhXszqFkuJ7HthRH1YD+RwV6dgwbHpQTvGNLNT8EBRfR
         D88A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=0ctFKY1Dn2SOXBB41lbEysb0dPgkRzW0iBsvqQk91OU=;
        b=n4L3mExx5+eXQJ7J79gXcmvvjoC3/gMyD0RTj7HnEZnlCROr4Xgo648yJf2LF+Ae49
         v/AreWWlKtEk/4DeYVqR6mPjotwZizRGgi0BHdjUwXY/p0hmcswviZAbMr6Om0waV6mM
         1GYyRZVl8DL4rj7njykiJbcYpGsJezOAg/K5U+uRDmSewU8izPRcpWUaG0kunPBmBwrc
         pveUng2oJaWewcx8vx3t2CfWz+3KJyN4aKERoul7HQOFXHl33rir5iR+LGvT+BqkBN45
         FygNQ6h+sz3TOb7J2PyN3+cXJSxGJ1WBZ1uzo5UfzCqqYxwiQbusjXWwNCfyMZxe47q9
         wybw==
X-Gm-Message-State: AOAM531kXn76LxB6Jbtw1GgAzFSxJgXx6v53mzYEH5/VF9YaKqgqoMRq
	4ukrbZPoS4XqG33mg27NJNnGG4z0iPA=
X-Google-Smtp-Source: ABdhPJwRZNFnQcCrZ2+w//6tqhbE5mVDn4g5ft1kXezw3dJ3TT4+y5r8du32rDQ3WDw6Xa05wuvfoA==
X-Received: by 2002:a05:6000:38e:b0:1ef:e106:bdc7 with SMTP id u14-20020a056000038e00b001efe106bdc7mr2046182wrf.551.1646048364916;
        Mon, 28 Feb 2022 03:39:24 -0800 (PST)
Received: from localhost.localdomain ([5.29.13.154])
        by smtp.gmail.com with ESMTPSA id e22-20020adf9bd6000000b001eda1017861sm10584592wrc.64.2022.02.28.03.39.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Feb 2022 03:39:24 -0800 (PST)
From: Amir Goldstein <amir73il@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	linux-unionfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 0/6] Generic per-mount io stats
Date: Mon, 28 Feb 2022 13:39:04 +0200
Message-Id: <20220228113910.1727819-1-amir73il@gmail.com>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Miklos,

Resending those patches with only minor change even though I did get
and feedback on v1 [1].

My use case specifically is for fuse, but I think these mount stats
can be useful for container use cases, either with overlayfs or even
with bind mounts, in order to help sysadmins bisect the source of io
from containers POV.

This revision opts-in for mountstats for all fuse/overlayfs mounts,
but we could also make it always opt-in by mount options for any fs.

Thoughts?

Thanks,
Amir.

Changes since v1:
- Opt-in for per-mount io stats for overlayfs and fuse

[1] https://lore.kernel.org/linux-fsdevel/20210107214401.249416-1-amir73il@gmail.com/

Amir Goldstein (6):
  fs: add iostats counters to struct mount
  fs: tidy up fs_flags definitions
  fs: collect per-mount io stats
  fs: report per-mount io stats
  ovl: opt-in for per-mount io stats
  fuse: opt-in for per-mount io stats

 fs/Kconfig           |  9 ++++++
 fs/fuse/inode.c      |  2 +-
 fs/mount.h           | 59 +++++++++++++++++++++++++++++++++++
 fs/namespace.c       | 19 ++++++++++++
 fs/overlayfs/super.c |  2 +-
 fs/proc_namespace.c  | 13 ++++++++
 fs/read_write.c      | 73 +++++++++++++++++++++++++++++---------------
 include/linux/fs.h   | 15 ++++-----
 8 files changed, 159 insertions(+), 33 deletions(-)

-- 
2.25.1

