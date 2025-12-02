Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB0FF220687
	for <containers@lists.linux.dev>; Tue,  2 Dec 2025 17:01:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764694881; cv=none; b=hr5vr4ZnchjA/lr9loj4hyRtcO33dh7D/mvKhI3s/y4f+gWzNu7ZZtw/R+M2wv72ZZ31A0xQ++uvZsRezB3blEM0bM6g+nUf5sjiczibh0ACWQh/jYq/TRuFnP5ztSpKnTh60z7ljKlc/W8LLqLd5VeAhk93QLwspMnN3wvQryA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764694881; c=relaxed/simple;
	bh=qRcGZFXKJMaKX/yvJKRpEH3ICexfqw2LvBvIVsUdxyo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=U7YVsyr6wxA/Rfk5v7gdJpp0+LQ0SVuNysMMqs+HTnioAd6ab2wLOmhrSEfp6f7zewKp6A9t32FpkAmLTnxpjQRL/uLbm9maFx5aumR9qJiwpBlKkdW2p59ySa+Se+dxLrUeZBn/t2w5HRgluLDuAbKzpI5LlAxR2wdAMXdi6eE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org; spf=pass smtp.mailfrom=linuxfoundation.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=e9Kt6Bep; arc=none smtp.client-ip=209.85.208.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="e9Kt6Bep"
Received: by mail-ed1-f47.google.com with SMTP id 4fb4d7f45d1cf-6417313bddaso9256293a12.3
        for <containers@lists.linux.dev>; Tue, 02 Dec 2025 09:01:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1764694878; x=1765299678; darn=lists.linux.dev;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=aKw8GaNp5Rdkt/37eGWeHQsaSq+KKpAjLZM3zt8c76s=;
        b=e9Kt6Beps5UQLbcKSHBcGF3+5fto+RLHG2ykgvkXHGAWvFtEegyuLcjqPWjIgLusFV
         9Rdgwn8M+bUjlZ5mclNDvtwD/eoD8NyTNxAcHg0WSF4y0U7NIDISxh7XKffbU+IHmBhi
         siFmzR6U4iWQsQtbivCGe/Ccyr9qftUMKFZZU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1764694878; x=1765299678;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=aKw8GaNp5Rdkt/37eGWeHQsaSq+KKpAjLZM3zt8c76s=;
        b=Z18IrkmU3VfPcNK2eD/TjZrNyFelSx3dqHOO1e3RnIs3eOODu19KXTlDY/jAOjjN6G
         bOf9UXcY35ctK105xcHioRBMqkjAOVir4aVinMv1I4liwBtp71LvdMCwB/r4svVPw3i9
         XAu9KigDbuEfcl3zw8EyfjcID1RoOxhy5xaczcWDkB8gcup0vlXs093ZtTkBwOCMwl2K
         vphJYA3Peq+hCHWNP7+OPZuQ3OxADcP4Ls3FQfUMnbmAxEozLBV6BeUGuyMGINRsWT4P
         pC2d+owLt37MUk3pcfA811O/A1Oj8YzaXlQ6qwwPsn51Y/EFrWqFcgEfp9XrJGdY/Sjf
         j8KA==
X-Forwarded-Encrypted: i=1; AJvYcCV9MQuIYXi6yIClMwgx+feiFiFd9XQs4Fl09VW32kGB6Hg0kHzFLcKr8GB1U7dgvF0T6/Xl5T+a+3hw@lists.linux.dev
X-Gm-Message-State: AOJu0YwdhzJu5/tdRUL5nPpeLg3DjpRkcHPuBqyheG2LlzlIQiedc9BI
	b/JBVlDP+84SOTGel+kjsKlzWmOFXWWkf25/CMfRy4AvBDLW3Y8582oYH66lY71NQNINKG1DJJS
	LZzACoIA=
X-Gm-Gg: ASbGncu6Ki59/iBr8mBfxHs/mYm8OkxGsDrO9Yy+L8EGSolfrT1H5kR/Qq862gX24+8
	EZYqCSlYpl+yDZ00HHj3Oxtv1Loq2qdQnB5OKkhwMEV2y2FKQqFr+vLCUlbHj8oodDo+PhPYU9w
	Oa/pGnPv91pZvMlpaqMxHrsJ6KMGEAplxCjS+lrSGvVSVqQpkbyXOnfpvnMW55dQO4+R9r4e1Es
	KJDV1kQNBrjuh4q9QsmfNSKESRGiNJtdAU4YI05AxlNie1QZeCB2oci+DY7X/apr1V3Y6naJGTK
	NjNQbbBEtv/hqtlbPqEvwTw/FEbI+UFod0ul2W9xh343sfA+Dr/3+QMTXm4hfiEzA7EhcCLggyn
	hxE6lhJ310eIcFj2cQk+4AekIUWjPSqeZULHjHBBaSlf8dw5CmPfFTQaWOeuNfCmg4q+S8YwAiF
	01eWEGRYnE/GriB4llliYvp9pio3Es1+s3jhYOV91910wk4VCYFzhba955DF/V4jOw+Y+X6l0=
X-Google-Smtp-Source: AGHT+IFikOU3axDFgXkuyV2rNstrDkaWQnhKl/IAZmztmxUqbXTuI+FpXaABnlDkFzrLCU5aR3iPDg==
X-Received: by 2002:a05:6402:2348:b0:640:80cc:f08e with SMTP id 4fb4d7f45d1cf-645eb78686cmr26521054a12.26.1764694877478;
        Tue, 02 Dec 2025 09:01:17 -0800 (PST)
Received: from mail-ed1-f49.google.com (mail-ed1-f49.google.com. [209.85.208.49])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-64750a6ea4csm16106718a12.4.2025.12.02.09.01.15
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 02 Dec 2025 09:01:16 -0800 (PST)
Received: by mail-ed1-f49.google.com with SMTP id 4fb4d7f45d1cf-644fcafdce9so9528294a12.1
        for <containers@lists.linux.dev>; Tue, 02 Dec 2025 09:01:15 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCU4PONBzko4pWR1I6zJCkIjnYN/cL/5pYEGrPpXkjsX7ZhJgTBJRfgI18XX85ZqOE557g6scrbv7kWr@lists.linux.dev
X-Received: by 2002:a05:6402:5203:b0:643:c8b:8d61 with SMTP id
 4fb4d7f45d1cf-645eafad307mr30539305a12.0.1764694874663; Tue, 02 Dec 2025
 09:01:14 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20251128-vfs-v619-77cd88166806@brauner> <20251128-kernel-namespaces-v619-28629f3fc911@brauner>
 <87ecperpid.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87ecperpid.fsf@email.froward.int.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 2 Dec 2025 09:00:57 -0800
X-Gmail-Original-Message-ID: <CAHk-=whPpVs67fAYWo4=SeD20cxjYoAE3d5RXgeHpXZ81uM7Lg@mail.gmail.com>
X-Gm-Features: AWmQ_bn2o0AS6BcgpiW3CE955dcwsPRXAVZIKXQGT7yckz2eOdb4b3Geamh17dM
Message-ID: <CAHk-=whPpVs67fAYWo4=SeD20cxjYoAE3d5RXgeHpXZ81uM7Lg@mail.gmail.com>
Subject: Re: [GIT PULL 05/17 for v6.19] namespaces
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Mon, 1 Dec 2025 at 11:06, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> The reason such as system call has not been introduced in the past
> is because it introduces the namespace of namespace problem.
>
> How have you solved the namespace of namespaces problem?

So I think Christian would be better at answering this, but to a first
approximation I think the explanation from commit 76b6f5dfb3fd
("nstree: add listns()") gives some high-level rules:

    listns() respects namespace isolation and capabilities:

    (1) Global listing (user_ns_id = 0):
        - Requires CAP_SYS_ADMIN in the namespace's owning user namespace
        - OR the namespace must be in the caller's namespace context (e.g.,
          a namespace the caller is currently using)
        - User namespaces additionally allow listing if the caller has
          CAP_SYS_ADMIN in that user namespace itself
    (2) Owner-filtered listing (user_ns_id != 0):
        - Requires CAP_SYS_ADMIN in the specified owner user namespace
        - OR the namespace must be in the caller's namespace context
        - This allows unprivileged processes to enumerate namespaces they own
    (3) Visibility:
        - Only "active" namespaces are listed
        - A namespace is active if it has a non-zero __ns_ref_active count
        - This includes namespaces used by running processes, held by open
          file descriptors, or kept active by bind mounts
        - Inactive namespaces (kept alive only by internal kernel
          references) are not visible via listns()

but it would be very nice if you were to take a closer look at the
whole thing and make sure you're satisfied with it all.. Even just a
"overview scan" would be lovely.

            Linus
