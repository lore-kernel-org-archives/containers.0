Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.49
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795830680;
	b=RfjpsLXs+TUDcoRHECIpR8ygHn0fVWgo6zeU5G+9KnjQ4wwkRaFmM+YCSneOVrn80oN4
	 HK32ncsjxA0a3BmlXfnMpyT4q/uLUvKGELwwzxDmrd93v6866gvYKsxaxdoOEPWGd+ik3
	 m5+y9eNIiYJ+ygQcgmD4UDU18z46RmLZT9qmCQ4yciZ7dZwlicw7AdgvGkQxBvMpYwKAE
	 mXcJJbQLvHh6eWGvHbxN7hi6Z2NDTtHxQIZHWY9dyxCdaSquF5ihK8XoZNb/f338ESaa0
	 pcWFvyQHWocMPqit8L2p7kogliX8cbmFsXV4veHv0FVC6emshajevSuGdlvvYXzIiKg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795830680;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=M+kv6M/MroHXNub3A7PdHe23Ap2KXe5JLqM78W2xjvU=;
	b=y26aeo315hFRNTUlVWQ/s64AY7uUCGj+kU8sVFDJ7BY4U8vIzyGbvFhBrOKBzi9ySDsU
	 o6wHZOKKHZUbXCDB+pCR+4Ie7s9C+j3sqm47URQ/ihwJSZw7Togt34c6+wlkZd/qPvCFi
	 q//ZbS252JGa9jQfmY72NS1Oj22mukYGF9IECHsm8ieZzUBIwdEk7mmWyKrS3sfR7Ue20
	 wH3SRFz3XDsjo8n2neuVyaKFGq17xwIzubQBNfXI54N7Z7K+DWc6dF3BTtE7o3SQtKvq/
	 zOhM5+bEd9AW4OicFibT2vIknWCU+vLoqWDZpPiTZ0MyOJnRMxyHxCNgDV6G+dWo3KA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yV2LYC0u;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.49
Received: from mail-ej1-f49.google.com (mail-ej1-f49.google.com [209.85.218.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CFA1606A31C
	for <containers@lists.linux.dev>; Sat, 28 Nov 2026 01:51:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6CFA1606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yV2LYC0u
Received: by mail-ej1-f49.google.com with SMTP id a640c23a62f3a-c50ac25cdd4so1088801666b.1
        for <containers@lists.linux.dev>; Fri, 27 Nov 2026 17:51:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795830679; cv=none;
        d=google.com; s=arc-20260327;
        b=loh/TMr5+mWbxWzyyDDrgAO/rBmFLD2kAP9v2oUdDqaGCGsAN35a7Potz3oWH/ybAt
         YzkxpkR+0RW39lFpsiyCSQXJEQozBsJaZMxW6Bx6M2+K34/ZZG2ZKENmdT1g47jc7P5I
         OcjL4ufY7tReBhIm6AbeAi1oDfiDhEJSiOP8fSZcSiWiVtnartu9q5Ojx8gW4z6wzf0o
         FxT+ZDmVosBEedyAoKRoG5gtgsR95OMgaZeOL1KaAOc2B5fI0va7k6NpEFgBljIukT2P
         REc2auE+ZEJHqjSjCsSzI1FrPf4So5Ky211YDZ5EUtjAOsU7DeeBWhMjOz17RRIcGWDJ
         Hx3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=M+kv6M/MroHXNub3A7PdHe23Ap2KXe5JLqM78W2xjvU=;
        fh=9QhlBnW6N0F6/QeB4bBkbo8KM2b1+4zfby5qKh4y+48=;
        b=Hm2VYCfUKX+8/Hp6oWjiIX6lQkQL6d7lraq2z+J09sEkKpelGardCdX5Br3WYE/B6x
         yqLkrl6Z3mWLAFt7//wGE/hHoaaQUYLm73BSkS8J4mtBfzmMXk9nPVV1PYtD5UvDYPKu
         VlQ4eh5Vf6qkeZ57m1ooqN8S99C1O7cO1P6SJpRnNid0ikAhChyIICrnLpNpFEUWnNHi
         E7VQD3K4hFcHBC0kyEKZg0yyHN6ZJbhuPX52QnxbvBbSdmD0+ouwWNjwAlHZjYWmYj4A
         7sMhzKGdmoRtWT93Ch7pUdjcRPHmN5J5AMirYHKqsYktO6it6SD92e1V+cxr4w4QpYij
         Zxaw==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795830679; x=1796435479; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=M+kv6M/MroHXNub3A7PdHe23Ap2KXe5JLqM78W2xjvU=;
        b=yV2LYC0ukg2Uf1BcaDHSZx6QFu/67zn2JG2/CnQQ95RbHUNzvsq4eORWidoGZ2+54m
         ipMEEa3ZeyTsh7FLEJx+zDNBh7lC141tcabVBglOjpNUGACctM3wwOAG4sEA/4szOMgI
         8fX6n6jColf6Q+EZQ/lXkqZK5GrLEch4GLwXPvGXhv1BwTi2jfCiPVohFzzo4Ga2JoYb
         fhrxXeQyBDDYHP+SQUNWa866af9PQd5K2oGyqYBVbQ7hjIi1vagSZ0ZWH9Dr59YCVITB
         rLjsPRYMHapqeb60Kq5IqjKCHjI56SSaofnyzo/F6X6yiYTgqDO8iW6kp1iFJQpuWoxY
         Qr3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795830679; x=1796435479;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=M+kv6M/MroHXNub3A7PdHe23Ap2KXe5JLqM78W2xjvU=;
        b=EIIQzln900vz65qO6nJ5XmiFycWiFO8bFQ5tiQKNWRKEgF6F3yMWwiMGWT/b2ZCoR6
         LB1Nr0BbJ3mMByQrNaRHLLJOBZ+KtoXH5UKNPQlsh5k3CWZfqlEnFTBuSOJjNAw//IWV
         hpbwDjyg0Z7eMNzgdqmA9nSBRwmB2HV7HLUnC+xcn/uTZxjLmKfQaVR99ZHj/oHqCrXp
         A5Kjr5eF5coig99ynSnwXjAGUPW4vxGzFQJiGz/yGi+iHbe9QKbimJQr5Wbg17uSk6Dq
         IHecz4j12rxP9BolHbkTUi+gbMf07qhS1+rymEWSHnryQq64IqCcndI5hJRApQKvHnNd
         0NHQ==
X-Forwarded-Encrypted: i=1; AL+hErGoUrL4gVGfrZ//9K/gADgKBs9Z0IGVCrND56pwZI7cpD6HVpn9/7gi3dlVHJtMygnio6FJD0itzoW8@lists.linux.dev
X-Gm-Message-State: APuU4Z90ZaIc8AIAo+WvZMQAIST6qPKY6y+Zw7dfGKysZ6LSLAfpfJlh
	xKHTj9CDsslWYV371047eLmXwOYnOxbCkaeYksk4PUn90iohhyivHUFEo7JypHL4lio/sRBvdKj
	D69ow4WcRtZxA0jUtmcFgw5GQ/IPeUBo=
X-Gm-Gg: AZFdTZeuqVmjA8zr08e88qs+ad8WHrRV7p/js7Ud4iAbu5irp4hujxaA+7t+MDJ42lk
	cDWdP88sxN4QJIiiv2Ddq8uBuacezXpFMY3atcYxPKCk/HZizrLA0bZoe3PmD2Zk4Q2bfUeArrH
	1PG56bpTnx+boiD07oHvOhaCQiriABHSkUIYOqdtpySDzrxadd5m4ECfOr+EXOeQpT4rueD2B6z
	Z/2G0vmh4vrmpF1b0wQv2IqHWTRhb0ztPVFnfG28TZok75Zuqw39A8m4NpL66hDiCBHVO+Xfuo+
	wTuuwd+ER7B8AecZXETdsLectZjkItRozpF5HeVdpClQfo7Rc4V+Kg+SeIZggO+lXyZ4N4OR9oS
	bS+bUd2q5Fk0z902s6MFzghCiWI7AwHTLfs4A
X-Received: by 2002:a17:906:fa82:b0:c50:4b6e:329 with SMTP id
 a640c23a62f3a-c513a5eaea2mr1724212966b.15.1795830678877; Fri, 27 Nov 2026
 17:51:18 -0800 (PST)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
References: <awOQDOel_72Xwjm7@kernel.org> <20261127214103.542291-1-safinaskar@gmail.com>
 <awn-ioAuksHNV-Rc@kernel.org> <awn_Y7oI4ckfsjSv@kernel.org>
 <awoHex4LVst2JwkO@kernel.org> <awoO9R7YF_5_6dHA@kernel.org>
In-Reply-To: <awoO9R7YF_5_6dHA@kernel.org>
From: Askar Safin <safinaskar@gmail.com>
Date: Sat, 28 Nov 2026 04:50:42 +0300
X-Gm-Features: Aa3M54pCi2p8qLdocdLXd3OCMkn8g_j_UUSVEEax8LAEOxwj1oFmxFAoHI8_4lc
Message-ID: <CAPnZJGBnFyrmr88OsYkMwtLiR93z4g0NAuoMurcnhcYFXz51jg@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/26] userland: Userland containers
To: Jarkko Sakkinen <jarkko@kernel.org>
Cc: aleksa@amutable.com, alex@amutable.com, alexei.starovoitov@gmail.com, 
	arnd@arndb.de, bpf@vger.kernel.org, brauner@kernel.org, 
	containers@lists.linux.dev, corbet@lwn.net, dhowells@redhat.com, 
	ebiggers@kernel.org, giuseppe@scrivano.org, hughd@google.com, jack@suse.cz, 
	jlayton@kernel.org, josef@toxicpanda.com, kees@kernel.org, kpsingh@kernel.org, 
	lennart@poettering.net, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	luto@amacapital.net, neal@gompa.dev, oleg@redhat.com, paul@paul-moore.com, 
	ptikhomirov@virtuozzo.com, sergeh@kernel.org, skhan@linuxfoundation.org, 
	viro@zeniv.linux.org.uk, zygmunt.krynicki@canonical.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 28, 2026 at 2:15=E2=80=AFAM Jarkko Sakkinen <jarkko@kernel.org>=
 wrote:
> thinking more sequencing than data structures. I.e. I have a game where
> I need to end up to process creation without embryonic state, and add
> just enough weight to kernel to support that outcome, and that leads
> to ~2K'ish LOC of extra kernel complexity.

So you don't have embryonic state? I don't like this.

Let's assume the following situation. Userland's PID 1 is already running.
Our container manager attempts to spawn yet another process into userland.
As well as I understand, it should do clone3 with CLONE_INTO_USERLAND,
and then execve.
This creates time hole when there is process, which already runs inside
userland (i. e. its PID namespace and other namespaces), but runs
container manager's binary and have container manager's mm.
This invites for bugs. Other processes, which already run inside userland,
may somehow take advantage of this.
For example, see section "CVE-2019-5736 Is a Very Very Very Bad
Privilege Escalation to Host Root"
of https://brauner.io/2019/02/12/privileged-containers.html .
So, here I like embryos.

--=20
Askar Safin
