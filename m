Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5BC071
	for <containers@lists.linux.dev>; Tue, 18 May 2021 16:45:58 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id AF84C601FE;
	Tue, 18 May 2021 16:45:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1621356358;
	bh=bERuiRZe9ZSLOiFNWknCvon0v6tNuzGcD0MRTu/YvXs=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=gicpzUe46UrSwOfI1A2OHw+RhCE/by0x8+Pq7lhV0Wa7YlwvyGTYtzH1BBhsKObPS
	 rWU18sgEW815ByPXMChdjReFS/qKWi1SQTnQHpjtyQFyO+2VeAH7f0kHvwcRMNb/0P
	 XDN3Db3B1b8vu5ejsuiOQ5XiZbSIiqtgm7ekNU832oo1gQrTFzAnA/XnA1Gg4QBAbn
	 HXz6pjy2BkmuSUWhTseDWM+Nb0CSJod7UBYVos6e/LCpleOg3OseTuspie4Gv7LY1f
	 A3s566VwEujzLEnTEttCv6IgyLfPKPCBiA1L5bmPy5jWb3uI3PNFRMDnfo7Vo9Hyy+
	 C1Qwu+xCn4sqQ==
Subject: Re: [PATCH v2 0/4] Atomic addfd send and reply
To: Sargun Dhillon <sargun@sargun.me>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>, containers@lists.linux.dev,
 Tycho Andersen <tycho@tycho.pizza>
Cc: =?UTF-8?Q?Mauricio_V=c3=a1squez_Bernal?= <mauricio@kinvolk.io>,
 Rodrigo Campos <rodrigo@kinvolk.io>, Giuseppe Scrivano
 <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>,
 =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@linux.microsoft.com>
References: <20210517193908.3113-1-sargun@sargun.me>
From: Andy Lutomirski <luto@kernel.org>
Message-ID: <ee341dde-649f-2803-c93f-2acc68b2e4f6@kernel.org>
Date: Tue, 18 May 2021 09:45:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <20210517193908.3113-1-sargun@sargun.me>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit

On 5/17/21 12:39 PM, Sargun Dhillon wrote:
> This is somewhat of a respin of "Handle seccomp notification preemption"
> but without the controversial parts.

Looks like a good solution to me, at least for this specific problem.
