Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795084976;
	b=4CV8lstXVgzjCTyw5a0qOC4VKlixFH3NhhDZTIRHR1wxClMdbj1oTGnBf9pPhAdAjHMY
	 seKRfA2QefJzysPSDDW1A+uDWjUbguH2Gbc9aJJ1NseVjUvzFXztaVqFyPaQ84ZKfJ3ci
	 g4oMN0iUi4JbnsbL5WLeGsRyVdIxJFN1jbrAv5UiGkJw/eCYa6jD+yq2mBB82IO5Yq8GH
	 pyTmG3AowtwxCH/CR9mqZK+BwLThgWbFwqt3lJXCmVA8GMWSnMZ3npw+iF+w3agJ5NhLK
	 ohJuvv6HE0G0nDzqjuV/i2QzkjkUU5prBwkO82W0iBhReW4JronUjjL3q5rVCSHnfVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795084976;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=u8ExomxaVoqynWwbL+tI4DQgA+MBylEC1NcrigkAqXU=;
	b=O01X5NjD+sX3xiyvo8jL3JMFkzOD6yiwsVg463TCKDVR8XnK0ggwovurMbFvyfZOX0j2
	 tbiwqPIsVwgm6RVE6swGZ1Wn1G/JW0/2qw3DKNbSrWV3HBjQvubfe8fR3ZEaZNWYj3wl7
	 wEEjk5HyJHRAx8eo+bj3aB8gYgDYBqvymuvN5iOrHR+2hzzWwnf2UqSMrI0x1ZViLaHyr
	 Ud+Amr8kGmcNwgdVgxS9XIYVhqX3ChdkXnObW+WPW6tPHPy+WJhUeUsQmP1QwNru4S0Ix
	 RQ1A3GdhTMVZt6fMGesHmwYIfdWiVRlSLsLbLC4HoWun74vaDKNeKhQ13632cjPC9dQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=E+UwAL7q;
	arc=none smtp.remote-ip=209.85.208.69
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3521C60A261E
	for <containers@lists.linux.dev>; Thu, 19 Nov 2026 10:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3521C60A261E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=E+UwAL7q
Received: by mail-ed1-f69.google.com with SMTP id 4fb4d7f45d1cf-6b8b0fff76dso1269275a12.2
        for <containers@lists.linux.dev>; Thu, 19 Nov 2026 02:42:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795084973; x=1795689773; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=u8ExomxaVoqynWwbL+tI4DQgA+MBylEC1NcrigkAqXU=;
        b=E+UwAL7qcN+3dYAId4OPeQh0rfiadMVNI7kcd2qVAdn09g2nKzrILo6VzPh4UTkoQz
         OeYMkW3YwGrYsVTdy/3AOwFJox+JqHyJdlfG8QnuTfHRSLjrm8vq1J7S60pF7hGPhl6/
         Dln1a/8G1X/vmuKtWUFvIUt72V6IAVIieNXaxOP59X+YQL8KnOqLhleub1b5ATxzAqjk
         E4L4p0jZm5sT8wFP2SdwlcYnI9PkMQ84sMKDH/vNQtSC8Ig5hlr6WulLp/d1fhyiT40m
         uE8nYlCcBK3i27P0Lf/G4xdQxju/tcaThQ1QljFfYDisSQFTLgxX3bidQTkd7msX7s17
         gbwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795084973; x=1795689773;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=u8ExomxaVoqynWwbL+tI4DQgA+MBylEC1NcrigkAqXU=;
        b=YaiXz89h4s2g6Eahcq0PK0d3x64ZgfoZGjpqeTIxv/cpYjiX47Gg0QNow5H0tSQXJP
         FusRNAmhXJtZs86xZ3ZSpt5VSF1q+A0p2b7XnLumnn7HRDNb++ZwIGEzguESrM0ENofR
         f1Rms/sJLuJ86JQHHwGzCg3E6RKdGIItae88bj2a01cUiVVbuqNGI+p+FHiB+V7tU9Pm
         7kFXV+x8NSDpaqMvdOC42XWnZR1oh5CQwVS3cP48VYhPxhCd0WUtc1yG1o0Mhxhf/KPW
         DnIUwuN9d26iA3BnnQBxTV257fV9nAjFE/dOvR7pxQscAmxK0rgWYALXBEIu/biEn+l9
         b+KA==
X-Forwarded-Encrypted: i=1; AL+hErFnVHQ0wb3gyH8mhkUL+7telPId8+6jD5KWtMXIAeAR0cZsqwB7uWZSZLnkaskYKhQhk+oEN2LuRZ/w@lists.linux.dev
X-Gm-Message-State: APuU4Z+fXfbS/6zQw8FWtsS4jB8qYUlNEiw6X1R1Y5djlqpkAk7vLC06
	BhXIwPzoXAPVRAX240dIKEyPbYipASosAhE4u28zIrl66Q+Hz+0eAzm4LqdkLlnT08sjFD09oA=
	=
X-Received: from edqs14.prod.google.com ([2002:aa7:d78e:0:b0:6b5:76e4:de9f])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6402:321b:b0:6ba:1347:5bf
 with SMTP id 4fb4d7f45d1cf-6ba13470764mr1098394a12.35.1795084972449; Thu, 19
 Nov 2026 02:42:52 -0800 (PST)
Date: Thu, 19 Nov 2026 10:42:07 +0000
In-Reply-To: <20261119104208.782900-1-halg@google.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261119104208.782900-1-halg@google.com>
X-Mailer: git-send-email 2.56.1.708.g77570a6a1d-goog
Message-ID: <20261119104208.782900-4-halg@google.com>
Subject: [PATCH v2 3/4] proc: expose userns capability mask as CapUns in /proc/<pid>/status
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: Christian Brauner <brauner@kernel.org>, Serge Hallyn <sergeh@kernel.org>, 
	Andy Lutomirski <luto@kernel.org>
Cc: Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>, Kees Cook <kees@kernel.org>, 
	Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
	Randy Dunlap <rdunlap@infradead.org>, 
	"=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?=" <mic@digikod.net>, Jonathan Calmels <jcalmels@3xx0.net>, Jann Horn <jannh@google.com>, 
	"=?UTF-8?q?G=C3=BCnther=20Noack?=" <gnoack@google.com>, KP Singh <kpsingh@kernel.org>, 
	Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, 
	containers@lists.linux.dev, keyrings@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org, "Hallgrimur H. Gunnarsson" <halg@google.com>
Content-Type: text/plain; charset="UTF-8"

Render cred->cap_userns as CapUns in /proc/<pid>/status alongside other
capability masks, allowing userspace tools to inspect a task's userns
capability mask directly.

Document the new field in Documentation/filesystems/proc.rst.

Suggested-by: Christian Brauner <brauner@kernel.org>
Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 Documentation/filesystems/proc.rst | 2 ++
 fs/proc/array.c                    | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.rst b/Documentation/filesystems/proc.rst
index fa7a468e8edf..9cf45810e41c 100644
--- a/Documentation/filesystems/proc.rst
+++ b/Documentation/filesystems/proc.rst
@@ -200,6 +200,7 @@ read the file /proc/PID/status::
   CapEff: 0000000000000000
   CapBnd: ffffffffffffffff
   CapAmb: 0000000000000000
+  CapUns: ffffffffffffffff
   NoNewPrivs:     0
   Seccomp:        0
   Speculation_Store_Bypass:       thread vulnerable
@@ -286,6 +287,7 @@ It's slow but very precise.
  CapEff                      bitmap of effective capabilities
  CapBnd                      bitmap of capabilities bounding set
  CapAmb                      bitmap of ambient capabilities
+ CapUns                      bitmap of userns capabilities
  NoNewPrivs                  no_new_privs, like prctl(PR_GET_NO_NEW_PRIV, ...)
  Seccomp                     seccomp mode, like prctl(PR_GET_SECCOMP, ...)
  Speculation_Store_Bypass    speculative store bypass mitigation status
diff --git a/fs/proc/array.c b/fs/proc/array.c
index f6f75d206762..2b86673aae00 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -311,7 +311,7 @@ static inline void task_cap(struct seq_file *m, struct task_struct *p)
 {
 	const struct cred *cred;
 	kernel_cap_t cap_inheritable, cap_permitted, cap_effective,
-			cap_bset, cap_ambient;
+			cap_bset, cap_ambient, cap_userns;
 
 	rcu_read_lock();
 	cred = __task_cred(p);
@@ -320,6 +320,7 @@ static inline void task_cap(struct seq_file *m, struct task_struct *p)
 	cap_effective	= cred->cap_effective;
 	cap_bset	= cred->cap_bset;
 	cap_ambient	= cred->cap_ambient;
+	cap_userns	= cred->cap_userns;
 	rcu_read_unlock();
 
 	render_cap_t(m, "CapInh:\t", &cap_inheritable);
@@ -327,6 +328,7 @@ static inline void task_cap(struct seq_file *m, struct task_struct *p)
 	render_cap_t(m, "CapEff:\t", &cap_effective);
 	render_cap_t(m, "CapBnd:\t", &cap_bset);
 	render_cap_t(m, "CapAmb:\t", &cap_ambient);
+	render_cap_t(m, "CapUns:\t", &cap_userns);
 }
 
 static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
-- 
2.56.1.708.g77570a6a1d-goog

