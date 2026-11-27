Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795815676;
	b=E1xcKGAfxJye5mkSIAjTwkOUEeEos3HnWQQ5p0kgCn1QTwfAnQD9hkoMtDZePyE38pQ0
	 a7AZ//LdTKViI97GeqIdIBXpQ8Y8g+AUdbwHwanlxAJCilMM+S1pfjh35JC6iTjdM2I3Y
	 dNaqxRkpCk0CPrHVxKqkeDzB5ujNVi6YLqVlZhEL0k+Zfi0tRoKnSU0NkPW9SPyfpz8Pl
	 x4/Cd4q2BhDx1GUqAjaemSNxrqnu3e/EEnYGLKLNa1/VN54cPcffwKRrLN05cQC1k1mnS
	 Jp1060CEId/dRfzkVFrG9HxXTxegUKk59NuOVPxt4LTc677njFMyBObq3QefoJwReYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795815676;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=GNjJtSmgBzeJqa75AyMuB1FfpMIGeExfgQrDDeRI15s=;
	b=0necf8iqbIBjQJ0iRrrI9lqtyVprGpPoBYb63HSatsAhcRPsuMTUseTpya87Hxyxk6dh
	 swCTzUyRAD2DEpY3nW9IX2X4ye13C3JBWtNxg7hmk0owB37cdPxgdN+J21/YpmUpNhd6U
	 1rUq/i2vDkMjR0bfM2o9w898DPsiowiJ1X82QIn5OMGYLA53klDy/6llstpGXbALTnVGi
	 LuXB+pLu5D6rb+NzWMyuBOwSuKeY1lhnIGeXIMz+BsYujdCX78OCojXsFsQLEdRBHHWR+
	 8PTM53JL7+iVqJb5vXGdmf1Lg7CT3fWd+PLOUOfiCW1Gxu1901kao3KfdV/Qzw1T2vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=GD9MXcrS;
	arc=none smtp.remote-ip=209.85.128.54
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FDE3606A321
	for <containers@lists.linux.dev>; Fri, 27 Nov 2026 21:41:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3FDE3606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=GD9MXcrS
Received: by mail-wm1-f54.google.com with SMTP id 5b1f17b1804b1-4bb666304fdso83008015e9.0
        for <containers@lists.linux.dev>; Fri, 27 Nov 2026 13:41:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795815674; x=1796420474; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GNjJtSmgBzeJqa75AyMuB1FfpMIGeExfgQrDDeRI15s=;
        b=GD9MXcrS4qB5wDNPR1hwS6KAJl9IfuzzTDuISde4RQFNswXf2RYE4Y2KyzRxnW9gpY
         QtXZ2P8Z6Hh9Y64cAhF2N7GZQvwwmEVMonio642hVQvoRMvMJg2CaV4OPwsYd1HHHMkf
         77Mj/d9H1PFQ16eqs0G8GJTIyNbmyI9SPXvaCx+S87CebyfEk2qvzzwhXXbK+oK9+lQU
         FPtnIBeeQwrAHN4STIi2FonOgHErs5NnnNKZdEQImKxw5cRX1oM490TP9WXwXoNssQ/r
         csHNJpPTppN/shfMQddxAWTgcWsK2mCcAsowjF22szgNWh8Vm9jxJYShqFNtG1tJHUsb
         FpfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795815674; x=1796420474;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=GNjJtSmgBzeJqa75AyMuB1FfpMIGeExfgQrDDeRI15s=;
        b=Y1RxFxClx6xNXbyBOedFmNNzxfT1LORcRhLRaZa/2kUWnXvyiVfn2VUPKp6rvi4gWA
         GC/H/YiYFiqvdPK5ZrWkDA4zbnDClkOfDHatC/axe/nZOOaZOoAnUjaKUOQZapTCrInQ
         TWXujK+AJkZeRMLs+LlzA3Ph7dyVNrfz5vc6VHQbpBjzeqJOur6q6dDUOU/LAvFyJLO2
         VCcYNBZwY29liB+Irw0PCW0KES5WSw3Lp2piyuteCYYniSPw9brL+fGLfOTSsm5QNmHq
         qCiY62AP0p4IgW3FUCtdAsqcN4o19bRIVEYQaeaqCGWjJH192+FyKIqK3fv6HN3iptCW
         mbBw==
X-Forwarded-Encrypted: i=1; AL+hErHgBzH1Z5/9eTXEjUfCJUBsA5a2jj3rl8oA6wo4Y6rY4pjKHdfFkPKDMiLkSDUPYco8LdDtBye0YiJM@lists.linux.dev
X-Gm-Message-State: APuU4Z+Q8wM+BZ+FKkpyByTIsmNK9L39RaWQijlVnn+ycMK0WCcXK8Na
	+oRh7gfm2eDitxCZpuiXddmn+5bMCJyGnDbW05tJl0iU96Q7BhZSp5zI
X-Gm-Gg: AZFdTZcZJKgIRHCGUGm3I7dqt42jRPdeKz39MXYkIBgOxVpf7ANaM1rU2eWSrYK65YV
	V09QHu9AaRHd3WdbakjnYray9rlyRrQZ2mwQPfxOXif6ZRCeWny3yHEOVuBVWHVr1iBJdCiCDid
	OXAoi41d2JuN8wrOyNg0wVfw2tegALUlR7VOxEniJaC/VZU1Gjt+7a2SsRUrKqq/f1DAy/+KQpV
	jw+Hwe4XwqkObny3PEaDybN1BHXN3REU0OUFux9uvdIEvWQ7zruJwSs8qezCcGKueqLdr3utufX
	KpA+vCeEf6NCClOnI5LfuIhwRpNjt/5kcD8yWNJMkipF14hMNPq8j+27ReEw9IDiX9of7cMeYd6
	mfgqZcng0njcf073ur5RajsRDNvbfOX3vVn/rvXjWYMdRjZhuibTqMLrPBsaIDe9Zjk7eJz8MQG
	1EFX7gHvqxTwcO/qdhQffPP2OAB5DbprdCIaqUUFmioED/buUNPbVj/ukWRm2EPGvaSIWNCtzco
	NGoVXKKgzGKgB/NrlkmD+IEoHInCzl/ODUxNqejDqVeWnZYR7Oa2IgwYjfzInBiaYWruIoiwu63
	TyX1N0oLavpwrPrafqLzBSDbZA==
X-Received: by 2002:a05:600c:a085:b0:4bb:85d9:156e with SMTP id 5b1f17b1804b1-4bb8880fe46mr518939935e9.11.1795815674386;
        Fri, 27 Nov 2026 13:41:14 -0800 (PST)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id 5b1f17b1804b1-4bbb97e5356sm37714445e9.4.2026.11.27.13.41.10
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 13:41:13 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: jarkko@kernel.org
Cc: aleksa@amutable.com,
	alex@amutable.com,
	alexei.starovoitov@gmail.com,
	arnd@arndb.de,
	bpf@vger.kernel.org,
	brauner@kernel.org,
	containers@lists.linux.dev,
	corbet@lwn.net,
	dhowells@redhat.com,
	ebiggers@kernel.org,
	giuseppe@scrivano.org,
	hughd@google.com,
	jack@suse.cz,
	jlayton@kernel.org,
	josef@toxicpanda.com,
	kees@kernel.org,
	kpsingh@kernel.org,
	lennart@poettering.net,
	linux-api@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	luto@amacapital.net,
	neal@gompa.dev,
	oleg@redhat.com,
	paul@paul-moore.com,
	ptikhomirov@virtuozzo.com,
	sergeh@kernel.org,
	skhan@linuxfoundation.org,
	viro@zeniv.linux.org.uk,
	zygmunt.krynicki@canonical.com
Subject: Re: [RFC PATCH v7 00/26] userland: Userland containers
Date: Sat, 28 Nov 2026 00:41:03 +0300
Message-ID: <20261127214103.542291-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <awOQDOel_72Xwjm7@kernel.org>
References: <awOQDOel_72Xwjm7@kernel.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Jarkko Sakkinen <jarkko@kernel.org>:
> I personally think that "getting in" should not be a goal in the first
> place. I care more about that whaever gets in has a high bar of
> quality enough. It can be something different than this but
> when I read the LWN article about Cells I was alarmed enough
> so that I had to do this and prove my point.

I think that Bacik's patchset has better chances than yours.
I think so, because (as Bacik said) it was tested in Anthropic, and also
because Brauner reacted positively:
https://lore.kernel.org/all/20261021-zeitig-niemals-clubmitglieder-b3973fcebd38@brauner/ .

So I suggest reading Bacik's patchset and say what you don't like about it.
You will have chance to influence Bacik's proposal before it will be merged.

(Note: I am not kernel developer.)

-- 
Askar Safin
