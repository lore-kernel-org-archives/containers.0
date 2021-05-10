Received: from mail-qv1-f44.google.com (mail-qv1-f44.google.com [209.85.219.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BD6C70
	for <containers@lists.linux.dev>; Mon, 10 May 2021 14:42:20 +0000 (UTC)
Received: by mail-qv1-f44.google.com with SMTP id q5so8418829qvv.6
        for <containers@lists.linux.dev>; Mon, 10 May 2021 07:42:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=InhY7G+ybOozbNoTmfhu8yZlE9kzFAP76imGYr8FuFs=;
        b=jjdppZ0kKSgG+x06elMGfD3fyyCV6FSKvtXjK+rgq8/wbwL4h4NX9wsmFGIEFMT0FK
         4SBvK6JS07NIZcXf58zIP9G3mIDKuUL6NxklgUgvycAMT3NKmmmLtjwqjiQZ4gIVAVZj
         vRAHQQo64j6ewLFvXMtcUYVknfiwxo6kaCrJddfxmjt/NCOWNic6hPmIys+qGz0G1KV8
         fofE57P7aSNqU1vWEHIkXeueS7hxUUaZ+ifMsX9Xk3ccJ/3eC5HLk0+CCWdakczYTj6r
         S1HW/xoWxNABQ7AtNSceHhXR9YeCHpOlXO7QY6PfdNT0jyAEti3V3GgZwOPUp2JQaZek
         UesQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to;
        bh=InhY7G+ybOozbNoTmfhu8yZlE9kzFAP76imGYr8FuFs=;
        b=sLzctrbRtRsbWkIU+whE2JmFZxnvHam2nPGry86s8ngYh0J5sO1AAgV60KMK+7idNq
         YpkqvNUipfygBSwIjX+iLfQPQBW8Yo5SHKZcQ/Z+/s8iLTG/J7/fMpgDPBT13fZfMWGN
         vhlk+/0BLYQxsFshqVM9rmI/EA0cpKTjNQeBW4WGToP87hbxrMrlv+z4Akw8CIOfozJu
         p7TxSO+mg3Fa1wjbzqWCOQJmxT5CV3Kjq6pSzfP323apdyPuTWtu2WBjN6/l39jMiitE
         nolkxEdxUa+wn/sPZudRAfoVOzWX8Mi6vaqiKaCu02iN6uMQqUYpouJPPN9AJ7JsDRLT
         gkdw==
X-Gm-Message-State: AOAM532Xr08Ce851qP3uW3xe92fD55fnFmzQ3oD5gLO0twt/7DMf2ajX
	UHMm+hGbI+t6spXllBNqNvE=
X-Google-Smtp-Source: ABdhPJyo0sICRY46JiwInz9mRIXGoQdUD1bcEQ238gnV4mkSakDM8KFkkC1rV8KurtigZBMnGkc1IQ==
X-Received: by 2002:a0c:fa8c:: with SMTP id o12mr23595836qvn.16.1620657739356;
        Mon, 10 May 2021 07:42:19 -0700 (PDT)
Received: from localhost (dhcp-6c-ae-f6-dc-d8-61.cpe.echoes.net. [199.96.183.179])
        by smtp.gmail.com with ESMTPSA id 25sm541511qky.16.2021.05.10.07.42.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 07:42:18 -0700 (PDT)
Sender: Tejun Heo <htejun@gmail.com>
Date: Mon, 10 May 2021 10:42:17 -0400
From: Tejun Heo <tj@kernel.org>
To: Christian Brauner <brauner@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Zefan Li <lizefan.x@bytedance.com>,
	Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org,
	containers@lists.linux.dev,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Serge Hallyn <serge@hallyn.com>
Subject: Re: [PATCH v3 1/5] cgroup: introduce cgroup.kill
Message-ID: <YJlGSZlZYaaujm2O@slm.duckdns.org>
References: <20210508121542.1269256-1-brauner@kernel.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210508121542.1269256-1-brauner@kernel.org>

Applied to cgroup/for-5.14.

Thanks.

-- 
tejun
