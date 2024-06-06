Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B21A14AECB
	for <containers@lists.linux.dev>; Thu,  6 Jun 2024 21:11:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717708285; cv=none; b=H+OZViDQYVE9NqHb5rcU0I2tmprlNloAnLAJcO1RazUWTLZ44/HRYka3pVhWRW8NaAuTFsillHWwSOQCn2W3HQrgxrWApk0z3IGlw2dszzGf5+k1HQY0FCUqzsEOjHjEMquEsma62h0BUr/gir+XAZpFRkYFjzZu/uBjNu6RDXo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717708285; c=relaxed/simple;
	bh=3zf3EcDcgRwvFL6Z73nBVv6KUiDmEEI7iwc25oTFd4U=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=TRljLMpy0MmymfQHfQfMVcQZsMydmVE9F7YY6hGDPlx7QhF5NaBbbM2lRJsaDq52+zz5DM9eHSp+rMpmXf2EkV/rWOt/DwsvZVTspNhsElDF6uLAMCe2LPHu2A+KYmPkMDZBg+7qHxshXx7WxSJYsmt/I7vo7f7/UwL+aONhOrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=stgraber.org; spf=pass smtp.mailfrom=stgraber.org; dkim=pass (1024-bit key) header.d=stgraber.org header.i=@stgraber.org header.b=obfbkvLC; arc=none smtp.client-ip=209.85.208.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=stgraber.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stgraber.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=stgraber.org header.i=@stgraber.org header.b="obfbkvLC"
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-57a30b3a6cbso1829609a12.1
        for <containers@lists.linux.dev>; Thu, 06 Jun 2024 14:11:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=stgraber.org; s=google; t=1717708280; x=1718313080; darn=lists.linux.dev;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=3zf3EcDcgRwvFL6Z73nBVv6KUiDmEEI7iwc25oTFd4U=;
        b=obfbkvLCA9Zni/mSKtJkR86kLVxbWD5pe7hDs1AD5BxIuKLXOkQbJimc72JayUyrmn
         D0cyZuPPVRBav06C3Jex5pdMnqHm8brOhF0D5Q08NR65fbdjEHISF0GeS5vgEs3hxNTY
         9Es1HsDFlyrEzLFeTIwYj/jRWIn8879BhTzVk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717708280; x=1718313080;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=3zf3EcDcgRwvFL6Z73nBVv6KUiDmEEI7iwc25oTFd4U=;
        b=pIxE/QpIj9cOm4Q7XwlpJWrqKwm4DUoHZpb/XuLoxwkjNx0upy1qR6uMB48oBfCBM3
         aoxBzIhgSIL8wMme7BvKaIr/yDsuUiM/2oR4bQCoAsrnjG90SEuW9oGN/JHLptfn1ZSn
         QMmOU6Qa/23Ng0mUf3IHAp12Hdo7HivnWxu0EwV8HWZAOsGXPeqzR+RVPqROzZ0o1Ag2
         IcG8D4m09BC64RV5v2U3GkgT91hApjSwQk6RTDItL7ZZWAK5FT0Vkdx5+fP/Ph1TsElb
         MrXSITKIpC5xdwSvSP2SbxY8HD+9jli5AP+6861A4MchH1DAOERt9udB/tnPSIHZmPvI
         HtXg==
X-Gm-Message-State: AOJu0Yzo/tvaKxLyc699nwv8B6QDUcT8M7kz/LK71wNM2Y3LZ7Kr/V3M
	3qds6syge9yzyZ7uxujDZTizcunEVw1mqTsOTc0jjgluSmZm7/kpI/Nbx0ZjNNoFFqrAl29p3vv
	QaJlcmLAcSta5lGAqYb2RjBRAKsNf7YLoUurXFtb9V4V2/7xs3Ko=
X-Google-Smtp-Source: AGHT+IGDHoMiZ7Fajbo0W+HPCyyjUSfreoCXjbxhz1b/cLpPCxict3mgf8pziBgEGm2fHiqitluHV90lfrCD81cG9l0=
X-Received: by 2002:aa7:c154:0:b0:57a:35f1:9969 with SMTP id
 4fb4d7f45d1cf-57c5095d2admr278021a12.28.1717708279427; Thu, 06 Jun 2024
 14:11:19 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>
Date: Thu, 6 Jun 2024 17:11:08 -0400
Message-ID: <CA+enf=tZs+B0OscmvyurqXjLwvwjhV7rZQ9-Rfi16BqAwUN6Cg@mail.gmail.com>
Subject: CFP for the containers and checkpoint-restore micro-conference at LPC
 2024 mailing/containers
To: containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

We're going to have the usual containers and checkpoint/restore
micro-conference at this year's edition of the Linux Plumbers
Conference.
This is going to be in Vienna, Austria between September 18th and 20th 2024=
.

Registration is open already and as a reminder, getting accepted as a
presenter in a micro-conference does not provide you with a ticket.
Everyone who plans on attending, whether in-person or remotely should
register now (early bird price until August 2nd).
Registration: https://lpc.events/event/18/page/226-attend

Back to our micro-conference, the CFP is now open and will be closing
on July 15th!
Topics of interest are anything that's related to containers,
namespaces, cgroups, ... whether in kernel land or userspace as well
as anything that's related to the ability to checkpoint and restore
processes.

Full CFP: https://discuss.linuxcontainers.org/t/containers-and-checkpoint-r=
estore-micro-conference-at-lpc-2024/20131
Submission link: https://lpc.events/event/18/abstracts/

See you in Vienna!

St=C3=A9phane
