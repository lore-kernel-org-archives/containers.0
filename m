Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795827354;
	b=QrqPeK09NHKvk4uwlNoGwZzatoUcEQV0mUgDoTX/PyWYwzavocL7xveFfQVyIXsTFf/d
	 LAwZAGM1PilNEDGz16p7FrBcY7rnKlXVRdr6/gv+OHJjKn55wkVMeNMDgpljKMtwDmqRU
	 ZjEwIuzYHhUMRu17GAyr6ea3tR4fAZYf7Vwyp2jRms4y64DBYM7op//xqc7oczZr0aYv0
	 g6XjXXouO6Ne22Z3A+bYp4s9dBDAGktbs9pca5DxFYxbfEbTJg4uthM6JGsKzaIDqSrl7
	 82hWgdMSzXlvFCqe2NY2VqsqzHRAn9BynenRcxd+dJfhs97J4D7tWiR00fkKu+EVI6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795827354;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=M4YJXz2C1qqMpFfvawPlwYq2ZIDKs+0ke0HB93yAMqs=;
	b=QT26mtnoBn4VXrT+DJRXvolBNm7KzA9uKPrtSpK02LRLyjB5MERRaO/BE2ma2fjn58++
	 UAWlIk/80oAqx9E9CZgheCKSrZTe+nhXXE/QXGXf4nMtLXP8SDScmXFLp64RpRQhHz8eZ
	 m4RTkSaLD1v23BEE8f/pURaippzbOwVWmF+pX41BRzhp6k0AkbFSKfDUhWb+LbHdr6ax+
	 UantDpTImkr77PpOs81pQadISKjBihnFuuW6i7wp/vKmsZj1+XNj2vmCh/YDOTRTiF7Tn
	 zna3ApqnxxHLHc0rjoxopd6jfU2BqVqzgz5hQ9EaTZ54jRRi9agRj18plZN3/0L0F4g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SakfClt3;
	arc=none smtp.remote-ip=209.85.221.52
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD3C1606A324
	for <containers@lists.linux.dev>; Sat, 28 Nov 2026 00:55:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AD3C1606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SakfClt3
Received: by mail-wr1-f52.google.com with SMTP id ffacd0b85a97d-4a68190a2a7so7319958f8f.1
        for <containers@lists.linux.dev>; Fri, 27 Nov 2026 16:55:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795827352; x=1796432152; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=M4YJXz2C1qqMpFfvawPlwYq2ZIDKs+0ke0HB93yAMqs=;
        b=SakfClt3Yehvp6KFlrvbqNnj8wgZiJHaXW7dn/l32c8wPnjeYHX+0Y6qZzaEB4WrDa
         9zqZzIpkil2DD7xRDLtQdaGBpp/4sYhMJnfjpPpzMv4VB/aUhnTUOcXpDJxcivqCnmwl
         8i2RPBqaEun71fsVdaYoPaGRz75DA7ooacy2kcKWKbVlCdmH3J2yIVzViPBrzx0rI6iU
         1s7QcDqssCcTo+HLMW/LoARr70b30MazSYn7Fy/j9eljE4Dl1tTOq7qVewYBd6bScmov
         2+57wfMigbCg8M4EiFeM1hED2j0tnQkWke5JtPJWcH0k8hHe83zPtVymv8G40VM8wLrH
         iuXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795827352; x=1796432152;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=M4YJXz2C1qqMpFfvawPlwYq2ZIDKs+0ke0HB93yAMqs=;
        b=vMx+TqkAieL1Q3/bacHBNqOIZDrPQkDtP+i+sDxVucgLwblGhrwheXWDghw7bWI8rf
         K2nFOHEsEzQPiQ7nnFK14e9KrOkT9NgaoSonhmpza3fuh8b+T7PAoEUp35fA6Xt5kiUO
         0CtB9OABHIf7zKxe1DSqQ2UwHgzpCipgPHrd6S2H71eeEQr99yPYGydqnOhEumKWDw7U
         lXpgeUie07cZQ8d1mByFj6FACRJcKbR98kg1tU/ZpruGBPWr1k3/nPHO7LbXd437uC78
         FNPzl6ZdWuo+zkSR1tvPBI90m1AJs3Jr0u+EGnXP2tj20HRKOKUdZJ3Ajo3LMpOipPgx
         v5YA==
X-Forwarded-Encrypted: i=1; AL+hErE5z0jsi3+QU9T4mXZJQK6+oCM6C89UIhtWZPWrvnpu4QjmD9WpRJOwWlyYdAS3V2lTYX4DLpCDa/N6@lists.linux.dev
X-Gm-Message-State: APuU4Z8GUXVBqj4hvM/sjvesn8nFLMV0qkctWkaUQ1yNMOEKWSnfH56W
	DAdj9ffZ7hlp6E5lBlLnqv3bEDmQYPGsnskGAiIR2CKxeSxU4XakFuOH
X-Gm-Gg: AZFdTZdDm6cHIemdhUp3kG6YUu59Xd0QbYMzqHjRne8f0z1qqdSxguE9RgRX5zNkE3Z
	KfT4arUL+pyCr85T52VOisOAB0bC090nNNlQYrTjkZy99lFRzBeD216nrIotOSWKIqHnCOfJH9R
	cboxGkoK1HBM6OEkOv5iLjtm6I6pB59egjsGOF/sCriTeZZAT5VjATZ3fOBsyRSvGVEn+l1SBuE
	tVSJa/HQyVIPL0oLlmggxIeYjgmXmRczV2I40c4iRNluka/cia+pTRnQABQPkw0Bo2KpGCvurgH
	PtWYZ+sDxT4B3jNMu4//D9h0Spt3XxX8pKr+Qf0LucueGgd9Gt6xF4f5GqgHDsntVcAC0Ac4nuB
	9S/TP+YlZf/m4NcWkCTxnjOjU63IKBK2nnkWjqlTFElc6vvBtxeKmDfytUw46cXO6qnwMaQz4NV
	5Rx0CFmYUU5iFuAuuuTaYyfeocBYdiZV9RMLjsAvsNAgtTRR6m2OO4KL1V52+cKr+5AlgJRm0Px
	fGohXFj4jlF50mz8WPeVXg6Wd6ebaCK5sUCW1TMz/ZJuMHQVTBOhOaJdTL3InUeGs0aXWToErmQ
	5aJM7cVQJrXVy0xrYINBWhKIxg==
X-Received: by 2002:a05:600c:4e0b:b0:49f:e772:6ddf with SMTP id 5b1f17b1804b1-4bb8881ae90mr541218935e9.32.1795827351797;
        Fri, 27 Nov 2026 16:55:51 -0800 (PST)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id 5b1f17b1804b1-4bb8538b09bsm1328407645e9.4.2026.11.27.16.55.48
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 16:55:51 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: jarkko@kernel.org
Cc: aleksa@amutable.com,
	alex@amutable.com,
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
Date: Sat, 28 Nov 2026 03:55:41 +0300
Message-ID: <20261128005541.873229-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261122193539.3334213-1-jarkko@kernel.org>
References: <20261122193539.3334213-1-jarkko@kernel.org>
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
> Work on this feature started in 2025 after reviewing David Howells'
> container object patch set [1], whose underlying mechanics made sense to

> [1] https://lore.kernel.org/all/155059610368.17079.2220554006494174417.stgit@warthog.procyon.org.uk/
> [2] https://lwn.net/Articles/1102593/

You put wrong link in "[1]". This is not Howells' container patchset. This
is Howells' fsopen/fsmount patchset.

Link "[2]" seems to be wrong, too. It is not something "earlier", this is
very recent LWN article.

> While the patch set is manually written, the original motivation came
> from isolating LLM agents

LLM agents are too strong for Linux containers. They should be isolated
using VMs or using some Linux reimplementation, such as gVisor.

Bacik said that he tested his patchset in Anthropic. But I think it
was tested not for agents themselves, but for something else.

Anyway, I suggest to drop this phrase from your cover letter and think
about some other use case.

-- 
Askar Safin
