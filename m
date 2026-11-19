Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795084974;
	b=vDFrvjrmilk+2qvyvmlz9ctMVgy1k5LJxHfmQFdC//iFe9ROlIlg3u1CpyQjeT+xlVoE
	 uF9dxH/n4Vuwiq8CfMz3NQWj/vujF7KGe6sLNj3NPX1h1HpLXFnAwqnR+1JVjKLEjs8vj
	 74cNxqE85X66JBTZGTKjSEIsyjI4iKmaf3l67m/ngjA5QnE+q2BNssxGNht5DfFS6vTJ/
	 tB6/Q/X7GrMvrjkusoGdKS/HZggWxmYTZWBposTbNNbY+tQbIcI4nxbQKYI0b1kZGumaY
	 scMcsoen0lVc9w31T9EaZ+f/OvibQi64QBub4we8hFAm2SOCzpawbzvnntLjmnanHLQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795084974;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=K0VpW7YvMhl0iK0xeqDJ+A8D6OVh/Im/AWHWGl8sSUs=;
	b=NBweaqwEmP6TfsbSE6lSYasgIfV2vTHXmzr6O5ctQeMDOWJFfkGHPziuFTmVhzz+3VtT
	 KhTzyma96kXf7Ro3PLjPqypg93n7WJNFYiGRIgI2XZRQrb7Ow4CqWOkws+FbV+TXpCRKq
	 cGVf8iLM1wc9dOOUYL5jQizYpwAQhal48q4NyJLkYto/dj5ZCBnZ+ZZQSyoNdDOstxQc3
	 9CeHWHQdzHlkJLUmZhgeLNekkJsouM6AWUopvn5iOjVpH3Oig8ax8YWlLLkIV/uCxz6AY
	 8SN3vBfNLC2VHs0zMTILhy2xLpsdE43W/oFr/BNCCnQYqklx+Tyqvrd5WFBXHFT1IVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=bUFDmYJj;
	arc=none smtp.remote-ip=209.85.208.70
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 652D960A2616
	for <containers@lists.linux.dev>; Thu, 19 Nov 2026 10:42:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 652D960A2616
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=bUFDmYJj
Received: by mail-ed1-f70.google.com with SMTP id 4fb4d7f45d1cf-6b7d9eab7ffso1797197a12.3
        for <containers@lists.linux.dev>; Thu, 19 Nov 2026 02:42:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795084972; x=1795689772; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=K0VpW7YvMhl0iK0xeqDJ+A8D6OVh/Im/AWHWGl8sSUs=;
        b=bUFDmYJjXqPDQej38BR/KbCJPRT7Z7i6iE2XMh5lFpRxCA+E9Xv7uLQ1tqOAqjYJEi
         8gCRyiOtonBolnsK0bkYUKywvw2aPZt2XekvOT9tFtGwpzg9nNCB0G7mDeTFKuLmk0oa
         3KnouVfejlhRt7qN4DH94IgaDn+QnDY5OnCB+LjwGYiGGaT3ilMq/U5WleD9J8R83Q8P
         XPPHcTdNR05QqOboHeRlq76wVovmxRnUGeUWN4bY1LM/OMAZECRcZa9eKled71I9NTxi
         nByGNKmg2S7F+2j9UQzOHKlyrvvR4/QPwxAKAvQygzNd9SNENYf7lBYMxSUCslQVOiIu
         aBHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795084972; x=1795689772;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=K0VpW7YvMhl0iK0xeqDJ+A8D6OVh/Im/AWHWGl8sSUs=;
        b=BDa3t5NwgkqzfGvyUkNJ09HwxO88YaKegRkk93ldlwvc74UQib0LbBhyeg0kBpf4zV
         pjfTw1MGt4/dekCwL7PAETAhI9CtdjXTrWwej/8fdVcR7orAWPMSLbzZSJDjlRtKw3Bd
         EIlglZxZj+mBuy8EQXpDU4tDKVXKO+1Uk09dJ69ZklRD8qHJq2+2HPAKkMcnJCb2smkN
         OwFxcCbmmDbuftnYKJD/QYsZqp8DsW0NwDMVlSVzqkg/AXjje0LAmytueLEbBb0dcRnj
         6+gLOtoHI0wqnRfbFU+Hpc23HojXVLKIgnw0BgaK3uyDwkZKrP/U5VTEjFiEptlLhSbs
         kgog==
X-Forwarded-Encrypted: i=1; AL+hErGaWKaNgpJ3robjoU4MKhyrHXsina2xALsEj+Ii9KiTqer4HdthTLuYobOR3LUCHDKdtkguqEVpXwjU@lists.linux.dev
X-Gm-Message-State: APuU4Z/VDc2Na48IBvZTs0rHFgp4uMVmjo9XiSUkM7n6hicfHV3dz0ox
	drxrflr6WkLuzqlP0cDFuG0GztjDJslkex8mQS6Nft4u95hBRHputK6Zu8+6ewtH9hP6QIWU8w=
	=
X-Received: from edev9-n1.prod.google.com ([2002:a05:6402:a2c9:10b0:6b7:77b0:4135])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:aa7:d411:0:b0:6b8:ac39:bb96
 with SMTP id 4fb4d7f45d1cf-6b8ac39c472mr2401311a12.12.1795084971484; Thu, 19
 Nov 2026 02:42:51 -0800 (PST)
Date: Thu, 19 Nov 2026 10:42:06 +0000
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
Message-ID: <20261119104208.782900-3-halg@google.com>
Subject: [PATCH v2 2/4] capability: bound ptrace and cred subset checks by
 userns ceilings
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

Same-namespace ptrace checks only compare cap_permitted (or
cap_effective), ignoring the userns capability ceiling. As a result, a
task with a lowered ceiling could trace a less-restricted same-UID task
in the same user namespace and use it to create a wider child user
namespace.

Require the tracee's cred_userns_bset() to be a subset of the tracer's
in the same-namespace check in cap_ptrace_access_check() and
cap_ptrace_traceme(). Cross-namespace implicit CAP_SYS_PTRACE via user
namespace ownership is already bounded by cap_capable_helper(), while
tracers holding explicit CAP_SYS_PTRACE retain access.

Also update cred_cap_issubset() so commit_creds() resets mm->dumpable
and pdeath_signal whenever a credential transition widens the effective
userns capability ceiling.

Suggested-by: Christian Brauner <brauner@kernel.org>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 kernel/cred.c        | 13 +++++++++----
 security/commoncap.c | 12 ++++++++----
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index d01df40a9a38..968122cdbf07 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -335,17 +335,22 @@ static bool cred_cap_issubset(const struct cred *set, const struct cred *subset)
 	 * the capabilities of subset are a subset of set.
 	 */
 	if (set_ns == subset_ns)
-		return cap_issubset(subset->cap_permitted, set->cap_permitted);
+		return cap_issubset(subset->cap_permitted,
+				    set->cap_permitted) &&
+			cap_issubset(cred_userns_bset(subset),
+				     cred_userns_bset(set));
 
 	/* The credentials are in a different user namespaces
 	 * therefore one is a subset of the other only if a set is an
 	 * ancestor of subset and set->euid is owner of subset or one
-	 * of subsets ancestors.
+	 * of subsets ancestors, and set's userns capability ceiling
+	 * covers subset's capabilities.
 	 */
 	for (;subset_ns != &init_user_ns; subset_ns = subset_ns->parent) {
-		if ((set_ns == subset_ns->parent)  &&
+		if (set_ns == subset_ns->parent &&
 		    uid_eq(subset_ns->owner, set->euid))
-			return true;
+			return cap_issubset(subset_ns->cap_bset,
+					    cred_userns_bset(set));
 	}
 
 	return false;
diff --git a/security/commoncap.c b/security/commoncap.c
index ddac8e917680..786f99eb6838 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -157,7 +157,8 @@ int cap_settime(const struct timespec64 *ts, const struct timezone *tz)
  * @mode: The mode of attachment.
  *
  * If we are in the same or an ancestor user_ns and have all the target
- * task's capabilities, then ptrace access is allowed.
+ * task's capabilities (including its userns capability ceiling), then
+ * ptrace access is allowed.
  * If we have the ptrace capability to the target user_ns, then ptrace
  * access is allowed.
  * Else denied.
@@ -179,7 +180,8 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
 	else
 		caller_caps = &cred->cap_permitted;
 	if (cred->user_ns == child_cred->user_ns &&
-	    cap_issubset(child_cred->cap_permitted, *caller_caps))
+	    cap_issubset(child_cred->cap_permitted, *caller_caps) &&
+	    cap_issubset(cred_userns_bset(child_cred), cred_userns_bset(cred)))
 		goto out;
 	if (ns_capable(child_cred->user_ns, CAP_SYS_PTRACE))
 		goto out;
@@ -194,7 +196,8 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
  * @parent: The task proposed to be the tracer
  *
  * If parent is in the same or an ancestor user_ns and has all current's
- * capabilities, then ptrace access is allowed.
+ * capabilities (including its userns capability ceiling), then ptrace
+ * access is allowed.
  * If parent has the ptrace capability to current's user_ns, then ptrace
  * access is allowed.
  * Else denied.
@@ -211,7 +214,8 @@ int cap_ptrace_traceme(struct task_struct *parent)
 	cred = __task_cred(parent);
 	child_cred = current_cred();
 	if (cred->user_ns == child_cred->user_ns &&
-	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
+	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted) &&
+	    cap_issubset(cred_userns_bset(child_cred), cred_userns_bset(cred)))
 		goto out;
 	if (has_ns_capability(parent, child_cred->user_ns, CAP_SYS_PTRACE))
 		goto out;
-- 
2.56.1.708.g77570a6a1d-goog

