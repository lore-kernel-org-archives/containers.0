Received: from mail-qv1-f43.google.com (mail-qv1-f43.google.com [209.85.219.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8C28800
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 04:56:46 +0000 (UTC)
Received: by mail-qv1-f43.google.com with SMTP id j11so6236657qvy.0
        for <containers@lists.linux.dev>; Tue, 22 Feb 2022 20:56:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GRsWtuYPVtPE9giQevMBeF9cuFJK/NvIt7pyCSw7hDs=;
        b=khJDE2iVvaglQeQ9LXMCz6SMrTJJkiLvNqBliBXOjiVSkmbE0fh9SqGgEBmv3MVW1Y
         zJJY6OdkCBe7oKFRmakwPUdhMOfv7G/BzUnyjG3tn1OLARgoW9m00aIBwZ2LqItgUSFZ
         wl8MwBHbk8fVAdFqRX4ZogseAeQ6+Je/QNn5Eclr/RELyXfhWWgGSmYgIFEK7kbY7gLV
         1x8sbmoI1QZcm5x5ms9Y7+dW2Hz7KHiqVLwfYwC/XTRIMLv4VgDiZG87nixRmf7YoJ8o
         b7qOo5QwXazdfDJzCBHJI0CUYiCdFD3FlF6temGs6Hs/rlQjzqQGn2EEuolGfWoIEhsd
         Sa8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=GRsWtuYPVtPE9giQevMBeF9cuFJK/NvIt7pyCSw7hDs=;
        b=YGYf6RWH+BIJbdkw/h5RzT0i7vgDscdqMb1Vv+KiZ/SadYfR4xJirKu4IqwRMeBjir
         3h++rwa1lWS8hVqUkNcGosZtzxynp/ffitAm8fKzZBtuRmMPWdiOgOeOQ381a1PpCbAL
         Y1laFMapIHuA35cpBnX+C5Zy38QS3mW2R54d/U4uMJPw9Dt1wrfPo8AL++JBFONawI7b
         jI1xNR/J1yO3sHiwxYzRprTAj6UF9YdHM4GJdEkjY9bxu8RnJkg+cpKWDdJC23fmyc8M
         GKoOMc9Lxi4LWwmg4QRsWy40pJJ5vs7TVkEa1SAzsLuS0YkFtXjj/lpXvoU1RTDPRTfS
         8kig==
X-Gm-Message-State: AOAM533uoK5i+tbV9d98a7Hvhe+xvnIN5+BaW26gdAoGAC00ksv8X0sF
	agSY9zWZCT5kZoPrlhO/0x8=
X-Google-Smtp-Source: ABdhPJwnF6BD9X6na/b400ybzxEnuRIEgmqgiA2Yc0f2crveMrPvg8r4nJnufal5GsBBQE4eQnFQGA==
X-Received: by 2002:ad4:5aef:0:b0:42c:3b31:86bf with SMTP id c15-20020ad45aef000000b0042c3b3186bfmr22102689qvh.72.1645592205740;
        Tue, 22 Feb 2022 20:56:45 -0800 (PST)
Received: from localhost.localdomain ([193.203.214.57])
        by smtp.gmail.com with ESMTPSA id 15sm398444qtz.89.2022.02.22.20.56.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 22 Feb 2022 20:56:44 -0800 (PST)
From: cgel.zte@gmail.com
X-Google-Original-From: xu.xin16@zte.com.cn
To: ebiederm@xmission.com
Cc: akpm@linux-foundation.org,
	balbir@linux.vnet.ibm.com,
	bsingharora@gmail.com,
	cgel.zte@gmail.com,
	containers@lists.linux.dev,
	deng.changcheng@zte.com.cn,
	linux-kernel@vger.kernel.org,
	xu.xin16@zte.com.cn
Subject: Re: [PATCH resend] kernel: Make taskstats available via genetlink per namespace
Date: Wed, 23 Feb 2022 04:56:39 +0000
Message-Id: <20220223045639.1932955-1-xu.xin16@zte.com.cn>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <87v8x678ph.fsf@email.froward.int.ebiederm.org>
References: <87v8x678ph.fsf@email.froward.int.ebiederm.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

>> -sh-4.4# ./getdelays -d -p 186 -v
>> print delayacct stats ON
>> debug on
>> Error getting family id, errno 0
>>
>> As more and more applications are deployed in containers like Docker,
>> it is necessary to support getdelays to be used in net namespace.
>> Taskstats is safe for use per namespace as genetlink checks the
>> capability of namespace message by netlink_ns_capable().
>>
>> Make taskstats available via genetlink per namespace.
>
> Let me add a polite nack to this patch.

> Taskstats is completely senseless in a network namespace.  There is no
> translation of identifiers into the context of the receiver of the
> message.

The interface of taskstats is genetlink that is sensible in net namsespace.

> To make this work requires updating the taskstats code to do something
> sensible when in a pid namespace, as well as when in a network
> namespace.

Yes. Taskstats already does convert the input process ID into the task in the
correspoding pid namsespace. Do you mean to add some check of current user's
capability like SYS_ADMIN or else?
