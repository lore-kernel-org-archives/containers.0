Received: from pricom.com.au (pricom.com.au [14.202.193.218])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28B9820E8
	for <containers@lists.linux.dev>; Wed,  4 May 2022 03:48:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed;
	d=pricom.com.au; s=phr1; h=MIME-Version:Content-Type:
	Content-Transfer-Encoding:Date:From:To:Cc:Subject:Reply-To:
	Mail-Reply-To:In-Reply-To:References:Message-ID; bh=YayLtC0WPVN5
	EDnxFhIUN1fXdtM=; b=w0GGaAdSWx8ZsqHm9WqrOumt2kI54A7J/hCtMkyObBuE
	9MpMNFLR+TWLqj8BqFFZJPDQDNTdG+q+VavpA/+4TUuZjwNYapb8rG+Zvz2AVHJp
	Apt01mxAnDXRcGN9dhcpGLM9hJGlUhtDiM58nN8Eu+6yhWqb749ZtrJdAOtM310=
Received: (indimail-mta 1395324 invoked from 127.0.0.1 by host pricom.com.au by uid 555); Wed, 4 May 2022 13:42:14 +1000
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed;
	d=pricom.com.au; s=phr1; x=1652240533; h=MIME-Version:
	Content-Type:Content-Transfer-Encoding:Date:From:To:Cc:Subject:
	Reply-To:Mail-Reply-To:In-Reply-To:References:Message-ID; bh=Yay
	LtC0WPVN5EDnxFhIUN1fXdtM=; b=lYk1cWKr7HM8sQAskUocTkSpmlLOCHw3P5x
	Q3T+WW/IIwfj9L3npxWiqDigGYqPUPw2cmyZGhKMh9D66JdnhPf9mVYcF7k8oBkW
	AGDMxg0DHv4jHDpZjX2hjueS4YCd2YDCfPwy1ZuPw8PCic1WqTtdeWS1CjZJu8LY
	3HYapWaE=
Received: from localhost (HELO pricom.com.au) (phr@::ffff:127.0.0.1)
  by 0 with ESMTPA; Wed, 4 May 2022 13:42:13 +1000
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 04 May 2022 13:42:03 +1000
From: Philip Rhoades <phil@pricom.com.au>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>, Alexander Mikhalitsyn
 <alexander.mikhalitsyn@virtuozzo.com>, Andrew Morton
 <akpm@linux-foundation.org>, Christian Brauner
 <christian.brauner@ubuntu.com>, Daniel Walsh <dwalsh@redhat.com>, Davidlohr
 Bueso <dbueso@suse.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, Linux
 Containers <containers@lists.linux.dev>, Manfred Spraul
 <manfred@colorfullife.com>, Serge Hallyn <serge@hallyn.com>, Varad Gautam
 <varad.gautam@suse.com>, Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [PATCH v1 0/4] ipc: Remove extra1 field abuse to pass ipc
 namespace
Reply-To: phil@pricom.com.au
Mail-Reply-To: phil@pricom.com.au
In-Reply-To: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
References: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
 <cover.1650631347.git.legion@kernel.org>
 <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
Message-ID: <94d3de676845342fa8abe0c90ee3c98f@pricom.com.au>
X-Sender: phil@pricom.com.au

People,


On 2022-04-23 06:44, Linus Torvalds wrote:
> On Fri, Apr 22, 2022 at 5:53 AM Alexey Gladkov <legion@kernel.org> 
> wrote:
>> 
>> Yes, Linus, these changes are not the refactoring you were talking
>> about, but I plan to try to do such a refactoring in the my next
>> patchset.
> 
> Heh. Ok, I'm not saying these patches are pretty, and looking up the
> namespace thing is a bit subtle, but it's certainly prettier than the
> existing odd "create a new ctl_table entry because of field abuse".
> 
> So this certainly looks like an improvement from a quick look.
> 
>               Linus


Thanks for that little glimpse into what happens with kernel development 
- interesting!

Phil.
-- 
Philip Rhoades

PO Box 896
Cowra  NSW  2794
Australia
E-mail:  phil@pricom.com.au
