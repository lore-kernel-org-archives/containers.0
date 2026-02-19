Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06B1F324B1D
	for <containers@lists.linux.dev>; Thu, 19 Feb 2026 23:42:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771544580; cv=none; b=CFh164mCMb4gVJp89j/h/Z9LgSASw8rjUKY9f/H4vB1MYpsub5MQXmRpiTHYOQ3IghX3XglcKAvbi201Qs/EcIdRtjdir1vStnn6sv9glmgcTfMB3QeKXqphJljT/BL96FvcKH/ao9RKUjt6hOSRJgKhx7yzmE/bBFsXlWvXAZk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771544580; c=relaxed/simple;
	bh=quE5sGl3Uk/gMNmwDYmHMacZa/Zg+chR5zy0mjgEh1Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JgkkghBPAqc8GJ6Ug4kvpHIBW+7DH7IyWnJSbeWoOysD9eCk2EvOKXsoG8iuLhBUb+CQHXd2xKMtelA9Rd5CLa/h8Wo4AiYwdRFXHVexKUttvZ65i01EBVAxIfFtKF7IVmPm/neM2ihPqSRqm81y9El9H2+O1LGdpGVNGw66CYI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=bDySFbup; arc=none smtp.client-ip=209.85.128.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bDySFbup"
Received: by mail-wm1-f54.google.com with SMTP id 5b1f17b1804b1-48371119eacso13733415e9.2
        for <containers@lists.linux.dev>; Thu, 19 Feb 2026 15:42:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1771544577; x=1772149377; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=VTF1k698GVo28+ckOqecetXyS8IP9ymt5tN+tdpIOiA=;
        b=bDySFbupf+3woGk6ad+NxfrM6DUbmFMebR3td0/ZJnwKAzK8lT3pv9By7IM+OENrhz
         O3c10BU5UUyKSMsxRZP70Uih5DouLXZAdPSlhZEodFZmNfrXAPa9/VwC/NUmtzA1tBuy
         YaD9F7jAMGkfVDumBdMWEK21G39eSV0TNVbXF3UUOiqmoxvcyB5R7KLA5twYuXgOAnwi
         oHbFO66d4zeIBl/pwgPlkbixndVpG2kpA5UearWxrjorpJpLdppK3szBXSQI/YjTYNB4
         V/c0XB5zATpoXoxOVj5pUzRwpsdqMt+SLc0GA46mG+MJYgyt0QJUh3roBS2Xw6XX519R
         TLIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1771544577; x=1772149377;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=VTF1k698GVo28+ckOqecetXyS8IP9ymt5tN+tdpIOiA=;
        b=lnq+7MGJ7GWXIs00opY+dL+KwhDo9EMkNwASEa5q7RLCxW8Uve5NOzuHSd0EJ/WY/u
         SPX8PkY5dUfcsKiXBVWMu+sf253uNPUeWWF7HmUxdu2F6JOITfV4tDfc0hAXWITD2h9F
         Ng3//kggxWOv2fWaKf6YfE3XrD5j/t3c9wQbF7NVlSNHTuAwCzMF+dQypY0W/Shsw/L5
         Ltd66pql+sOE1V9RoSdXZGt/Tvv8trebv4xsTtJ/tIlta1BpgRA+9MtHSTjAJtBCOGTT
         /5tTDLwEBQObe44GuQJClSjoTHSpbzclqlmHD3IpvEs9+atJSqmXZRB5MKqAYLaYbMwE
         2NhQ==
X-Gm-Message-State: AOJu0YyPboPgUDyCpYKn7NbWEBdSx7y6/aFYMOzyG23MiHlaxzPYS+/l
	FnbUzrAqPn0i7gwWQlI1YrjJFPF5bzvSzm5Nb4FD5PBftUI2XijfGEI1
X-Gm-Gg: AZuq6aIymvrCK1+naz2LKlY63W+2tjmKh5igCNPw8GwZq+epGEiQFhkDWSganHPj6Uw
	cNSLnIIQe1jIuAu7k41d1Knv4Xo3bYAWnJoVh/in0JUPqHYZ5G82ex+eZjBrm5PgNdhfZECNnEA
	s/Qb1ZwA47VHXQ3VnVivNZz9aqGrV3mZNqZoKPAlRhfMBGVr/lDQxflI2PJOhkfLatcvbx7t3TM
	RzFnLnTMqFvFxOY4KTDAww/9Abd6eh4UaJXOMYyQbNUW0UnKJjbQrMhzKcj7ZYC23o1qhxepFP6
	+ujTZxxZzhrv2R0MmMp2RNnlISs0s11HA4Sf30n7D9L79/im2TaA2Uizs9MWdL1Theh4TPNF7Dh
	EuP4eNR6HLyGT1eNOAwtDgS01cFFrXbFR3hYRlYEoP4In4Rc1KGQiu0Jcb8pa64pXL5UAopOnoP
	SiQWO3tBlRPwQqaUQ8oN0=
X-Received: by 2002:a05:600c:4e54:b0:480:4a90:1af2 with SMTP id 5b1f17b1804b1-4839c002d65mr111614985e9.35.1771544577127;
        Thu, 19 Feb 2026 15:42:57 -0800 (PST)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id 5b1f17b1804b1-483a31c048bsm35793735e9.7.2026.02.19.15.42.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 19 Feb 2026 15:42:56 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: rob@landley.net
Cc: containers@lists.linux.dev,
	initramfs@vger.kernel.org,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] mount: add OPEN_TREE_NAMESPACE
Date: Fri, 20 Feb 2026 02:42:49 +0300
Message-ID: <20260219234249.3757808-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <6375f293-709c-41b8-a23d-12010baa3cae@landley.net>
References: <6375f293-709c-41b8-a23d-12010baa3cae@landley.net>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Rob Landley <rob@landley.net>:
> Also, could you guys make CONFIG_DEVTMPFS_MOUNT work with initramfs?

I did something similar:
https://lore.kernel.org/initramfs/20260219210312.3468980-1-safinaskar@gmail.com/T/#u

Does this solve your problem?

-- 
Askar Safin
