Received: from mail-yx1-f51.google.com (mail-yx1-f51.google.com [74.125.224.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67BCF20FAB2
	for <containers@lists.linux.dev>; Sat, 24 Jan 2026 10:14:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.224.51
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769249672; cv=pass; b=GRO7wfm3E02W7q6gBwRKoNu4nOYdgTn3Sbx9LLFIp5yceVUppyLrjvwW5UBG2fHUKCWGJChO2B2CNISWXFtgnhsaP1GmUSmEJaJb6LbdbNdzcNP5dNr+JPYgGl8qN6uQ2U/i8tx5QTl2IHecL+STHLH7Xq8LxfOoDVpNJYwnY44=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769249672; c=relaxed/simple;
	bh=7MM3onG4tUxgwOKfJm5InIVjKBkXtm5OCZzzHG9w3m4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=dHhlgKwdG76c4awXmWwUeW75SpUP/m04SsS6WLvqeX4lbccDjg7CtZHvtbhOz1vLc5NF69XOd8cYIII1BF3FZ4dtr5eC5rEmx/OZWE1fP/Fn7qnUut23+/5tZekh0FIXleGUCPsjEw4BH5LDux/eUs8W3FjYtiwjI9ttbMwulEU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lVmbcPYi; arc=pass smtp.client-ip=74.125.224.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lVmbcPYi"
Received: by mail-yx1-f51.google.com with SMTP id 956f58d0204a3-6495d592c45so1619612d50.2
        for <containers@lists.linux.dev>; Sat, 24 Jan 2026 02:14:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1769249670; cv=none;
        d=google.com; s=arc-20240605;
        b=FUNxIb4WBj9usnP01eKJ1UkQDNix2+DcToMmP6FC6od3um82j66ahyJ9e3B6K/OuKV
         e0ljQNkg95VfhkQDpQq/0aHgU4e5OPIpLTCVDXhzS2fNU9nbbFqU7LiEX966a3irMtIe
         qQuTs77oTq2SaNcZ5syzPFRH3dcIagY1ZAgbiTmMAiznJFcv3R2gx3fMWy93QWW+abRZ
         FmBbszxjSmZ15UTCDw59cwp51ttx1rLx8MGTmjULlLY451EXzSxCqgAhAdMufcu95Sdm
         BmUZ13dL/jP7uob5nsu1rQ0b082GpwVJ6iNeqY6GQi0vYQUpbxctm7eXTy+YMwXdmXIY
         bQcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7MM3onG4tUxgwOKfJm5InIVjKBkXtm5OCZzzHG9w3m4=;
        fh=eyNKQDV2lOs5Cx7t6H1A8Tyjfj2nhRsKcySoUwBopiw=;
        b=K+zVlnEVPowJz6suEQt0GhImMpheraUau4qQ0XxKsdR99r2L+snCxuHqtGA3YOPlQL
         4I8/wbsgULwHFthQTb68YdvWzGhRU+TuHVp+Au3K/A33lP4TuFj0eXrX0GANlf4GvmXo
         lCNhTkNLh8dMfX1n2ArTG9lfH76Y/a2hi4Y37MOQUTiPU814q07kkiqi2l+VZVD34jE9
         j1WfUAea7FaWOXJFOwSp8kqWId6hNWIBL/4Kidme0HTUpWTjomxCN5WC5ThHaE0XtJqg
         iUf3HiF6hYpZrxfZXeFSMJ62OViKigdDgHQmohKQWKdoQvkKYKFUb6WSshBnjqgt64y4
         qSGw==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1769249670; x=1769854470; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=7MM3onG4tUxgwOKfJm5InIVjKBkXtm5OCZzzHG9w3m4=;
        b=lVmbcPYi6mbeH5wKZ3XYljptcDUQ0m2Y/W/KD0PpuOWa+Nwnv2qdWebhtlx1Jjm8p8
         D7OT+gAIINRhjxYLXkGuE9y6svBdnsEfQdSAtj41aL+tg0bYOxyS7lYCL3jopifAXhpI
         baVNDu6rAZxHVg9ZK5aakGAO9vJOxbItO5QJYWKDOBpnkEcAtpkLUKOknYGLc5CQEvdH
         UzBZN4OMswRwlomQrxzgD4n2SoKfGgd6KiWDKMiXtTEnyTLMGCnaXfFHNOO59sL/FaWm
         rGD06VxnTaN8x6d9XIJ2vdthVDAHawYTyujoF9sIVNy8GJ+w6Of/yUxTXWtAaotRJkMc
         RTsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1769249670; x=1769854470;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=7MM3onG4tUxgwOKfJm5InIVjKBkXtm5OCZzzHG9w3m4=;
        b=gWwP//9vhV+rhLLZu9jnahZ8T/ZNQbqNnTkgxcQMZ+F7yVREggKFfKhMiZVgY7nmVz
         86rVUDn3Iqepxrnsrh/okpL6Y2xOqS0otdUaSilgQsavkfeQEBLXt360lhvLHWaS2b24
         gdfaln0+BrdzJgIR6VkF1gBwo+d5L26dSWJu4QqodrVZD0tdhkDAwAzhpyvl1kFjIO6U
         rDohjX6wyQhymojSL7pnihFqVNY5T1mnLKYP71WWt1wv+ZtTn8Ia8GkOIJ3td12vUvDT
         JXOm7NyV7Ga34/+3Z9qNdz14DdURFQhOTHr2Nmt5gV4KtqFEGiavhspVB2KIFv9p0Ztg
         XhfQ==
X-Forwarded-Encrypted: i=1; AJvYcCV84Li9yWPL4c2h9Vy8lLH8EP7eQdP7T9358tvkvOWovGvDG8oAEqL/sMmqNwAxr6zJN9+VdLYtoUa7@lists.linux.dev
X-Gm-Message-State: AOJu0YyUQuga3T0stPOqUnpGNv1PzH2XsaiZh5ckIui4isjiqHptRyfY
	DwC/pXtpwhewDLLUJWxXQZQkTDD9f/4DFJs3ppOLpGK3kpsNqfBnG6RqEB8v/eSvHxJrT+IEyOb
	pYp47v2LsXNoq3m8yZgJxoEns19tcRdQ=
X-Gm-Gg: AZuq6aL0eOJdXYf770RpJR58ses3MiMhkUniVNZ78LeijV5df07ll/1A3JghlkHKaw2
	cAbdrcBV4wMkBG+3iMmmIKDekpwNpQP3PLw/y0eXdLgeEjjqx/PUWgZD3yZsfEAmGqhmEscN0sJ
	F92l2SPLzmCQCROKXMxIHYhY3ogdC3TrTh6SwH6e3zImUF/xA74vZGVj9OCyIPxUg6fbJz+lFx1
	UosG1sYnJsU9+nSIVb9muIEt+J4jSRVzQFUfGSFyctb8hQErhYiPouRDp+m1y30Fq5xGgA=
X-Received: by 2002:a53:ac82:0:b0:649:3970:fa88 with SMTP id
 956f58d0204a3-6495bece06cmr4745338d50.37.1769249670198; Sat, 24 Jan 2026
 02:14:30 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org>
 <20260119171101.3215697-1-safinaskar@gmail.com> <CALCETrWs59ss3ZMdTH54p3=E_jiYXq2SWV1fmm+HSvZ1pnBiJw@mail.gmail.com>
 <acb859e1684122e1a73f30115f2389d2c9897251.camel@kernel.org>
 <CALCETrUZC+sdfpVqqjeC_pqmd+-W84Rq7ron8Vx9MaSSohhJ2g@mail.gmail.com> <20260123-autofrei-einspannen-7e65a6100e6e@brauner>
In-Reply-To: <20260123-autofrei-einspannen-7e65a6100e6e@brauner>
From: Askar Safin <safinaskar@gmail.com>
Date: Sat, 24 Jan 2026 13:13:53 +0300
X-Gm-Features: AZwV_QgI2djWv53heJq45UjjcmWS5t43scQ8_DAQPG3PfhZnXr_aF6xvpALbmMM
Message-ID: <CAPnZJGA7jbQAAV09Lr+NKNwRvKmegZFC=LzOZybWG7skF4rpQw@mail.gmail.com>
Subject: Re: [PATCH 0/2] mount: add OPEN_TREE_NAMESPACE
To: Christian Brauner <brauner@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Jeff Layton <jlayton@kernel.org>, amir73il@gmail.com, 
	cyphar@cyphar.com, jack@suse.cz, josef@toxicpanda.com, 
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, 
	Lennart Poettering <mzxreary@0pointer.de>, David Howells <dhowells@redhat.com>, 
	Yunkai Zhang <zhang.yunkai@zte.com.cn>, cgel.zte@gmail.com, 
	Menglong Dong <menglong8.dong@gmail.com>, linux-kernel@vger.kernel.org, 
	initramfs@vger.kernel.org, containers@lists.linux.dev, 
	linux-api@vger.kernel.org, news@phoronix.com, lwn@lwn.net, 
	Jonathan Corbet <corbet@lwn.net>, Rob Landley <rob@landley.net>, Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 23, 2026 at 1:23=E2=80=AFPM Christian Brauner <brauner@kernel.o=
rg> wrote:
> The current patchset makes nullfs unconditional. As each mount

Oops, I missed that "fs: use nullfs unconditionally as the real
rootfs" is present in vfs.all.

--=20
Askar Safin
