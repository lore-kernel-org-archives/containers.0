Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 432F670
	for <containers@lists.linux.dev>; Fri,  2 Jul 2021 15:20:06 +0000 (UTC)
Received: by mail-ed1-f48.google.com with SMTP id h2so13747841edt.3
        for <containers@lists.linux.dev>; Fri, 02 Jul 2021 08:20:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kinvolk.io; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=06Nd6TnCb3nAEOSv6yJcw8Ps4KFQ2U44qABFJzU7ha0=;
        b=Tb/6zZy4QHtUFQ/eS5cHy+sIGYIkdjTd200ybkGsGXbXYWCEALMoQDLxmcoiNdrIgI
         cfY5xLUYk705kgEv0XtIyadG7Cxb56eW5w9P04fb7WrYDhByCRSAOpJanGBrr38sDSRN
         i2mVFrn7X4L/Spm4WwxNuzxYnFfv4dOyXp18c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=06Nd6TnCb3nAEOSv6yJcw8Ps4KFQ2U44qABFJzU7ha0=;
        b=N7D3ns4P65d4y7z+araRPO9TQLC0zbIRwwZeVThbNTMTAXeldIPo5keuYaVB0FaZFm
         EsQ4McAe3QqHY60HcSsTqTBAhQSdFEUuhLiU7mrOFqLK5YW1S87HJ0fglTdxA321nqWc
         bivoKc0sMHPNYbtQTwO5pZ90ba7Ki9+35HGYuWMfgHfIzMuXuM9XevnVfB8Jyj0FfUfQ
         Ulbvjbr87i0YGZ51g7xoJ4opqSaz8VnBG2Ybyuuhkt3vKjGgXnsr7IsQ50oFFnbYBATf
         1wO0TCs/QtkhMse7uyJZ1p64FUst/d6TmdwwkswwBcr4wqVYhHLhqwWbsjSBRSF8BxIb
         F9rQ==
X-Gm-Message-State: AOAM533eFqgxryoCoQyxdLfOHdt7+aH9Ewqcs0c8y/hKX/yJYdsly7la
	Bx7ZoXO4MEV058N8og6bU+uk4Q==
X-Google-Smtp-Source: ABdhPJy1u5wCKlcBTOsax8/gzE7py/1SbgaTWjGsn//HbIVqC6hXhZ/ySiT8Gf+pZZArQ4zCrVvkDA==
X-Received: by 2002:aa7:ccc1:: with SMTP id y1mr7348581edt.321.1625239204808;
        Fri, 02 Jul 2021 08:20:04 -0700 (PDT)
Received: from localhost.localdomain ([2a02:8109:9880:57f0:ba7c:cdd5:fff7:623c])
        by smtp.gmail.com with ESMTPSA id c14sm1508402edr.27.2021.07.02.08.20.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Jul 2021 08:20:04 -0700 (PDT)
From: Rodrigo Campos <rodrigo@kinvolk.io>
To: Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Will Drewry <wad@chromium.org>,
	linux-kernel@vger.kernel.org,
	containers@lists.linux.dev
Cc: Alban Crequy <alban@kinvolk.io>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Sargun Dhillon <sargun@sargun.me>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Christian Brauner <christian.brauner@ubuntu.com>
Subject: [PATCH] Documentation: seccomp: Fix typo in user notification
Date: Fri,  2 Jul 2021 17:19:27 +0200
Message-Id: <20210702151927.263402-1-rodrigo@kinvolk.io>
X-Mailer: git-send-email 2.30.2
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The close on exec flag is O_CLOEXEC, not O_EXEC. This patch just fixes
the typo.

Suggested-by: Christian Brauner <christian.brauner@ubuntu.com>
Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
---
 Documentation/userspace-api/seccomp_filter.rst | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
index d61219889e49..539e9d4a4860 100644
--- a/Documentation/userspace-api/seccomp_filter.rst
+++ b/Documentation/userspace-api/seccomp_filter.rst
@@ -263,7 +263,7 @@ Userspace can also add file descriptors to the notifying process via
 ``ioctl(SECCOMP_IOCTL_NOTIF_ADDFD)``. The ``id`` member of
 ``struct seccomp_notif_addfd`` should be the same ``id`` as in
 ``struct seccomp_notif``. The ``newfd_flags`` flag may be used to set flags
-like O_EXEC on the file descriptor in the notifying process. If the supervisor
+like O_CLOEXEC on the file descriptor in the notifying process. If the supervisor
 wants to inject the file descriptor with a specific number, the
 ``SECCOMP_ADDFD_FLAG_SETFD`` flag can be used, and set the ``newfd`` member to
 the specific number to use. If that file descriptor is already open in the
-- 
2.30.2

