Received: from mout.kundenserver.de (mout.kundenserver.de [217.72.192.73])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BA65173
	for <containers@lists.linux.dev>; Mon, 14 Jun 2021 07:49:55 +0000 (UTC)
Received: from [192.168.1.155] ([95.115.71.85]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.183]) with ESMTPSA (Nemesis) id
 1MqJZl-1lW3zE1cfr-00nQqE; Mon, 14 Jun 2021 09:49:23 +0200
Subject: Re: device namespaces
To: "Eric W. Biederman" <ebiederm@xmission.com>,
 Christian Brauner <christian.brauner@ubuntu.com>
Cc: Hannes Reinecke <hare@suse.de>, gregkh@linuxfoundation.org,
 containers@lists.linux.dev, linux-kernel@vger.kernel.org
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de> <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
 <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
 <20210609072108.ldhsxfnfql4pacqx@wittgenstein>
 <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
 <20210609080918.ma2klvxkjad4pjrn@wittgenstein> <87v96k1d65.fsf@disp2133>
From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Message-ID: <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net>
Date: Mon, 14 Jun 2021 09:49:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.0
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <87v96k1d65.fsf@disp2133>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: tl
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:vDcC/6vJGgs0xNiN8kqUu/HqX+nxu78r6MTjnn+RaYLuzq9x4kM
 3AyrUtiJ4LfMoeezJW1RUrxpG3wlUPedT8vY7Posz4/koSgZ3bkxlF7O/vds1Zss5qK7a75
 aN96WycM772iK8O5+zblLAgmJrH947YEJwxNEzqiq7iP+ruA4XFHBmRiLMbgWvPW0Be3rrj
 MH4E5Y49mVP4cmczWyz3g==
X-Spam-Flag: NO
X-UI-Out-Filterresults: notjunk:1;V03:K0:doK3sJdxH9U=:XMd3gz1LgI4ifBd/cLxrAS
 RLRlLPtxMnFJxzMHKxJPACZ9b+ex+7B7ul616LdwW1mrQshlwvpwnFbWqWZCcbb6eVhvE8MB2
 yxokDoMeqAmfyDW/xCHel32Q1ejOU3cSrBYgbj24tFqnjhqDOhCf+fbwSnsJMQpeV/EoU8Rhk
 c4yEge2gIidmm7SP+tQX5jbqSo8ah5czMjDUJyJs2n9mhXsr0K/yVeICvbDKlh3MaECOAcf7N
 m7fv6+e9Tg43z+kazu4lT0KC7eqie4KygXdMLYQ7FBUzWw8N1xOMFkA7fW2gc9wfUXUctaq4J
 jZp3h90Zf2MhGixNNKjDshLXzTEfs5Mra7Xpx5QhXmw6FvCXSKsi7ofMGpLKZXKXtke+++O7/
 nVIddDzBsCE8/TrJXxDL1RZzLhgg99BqI1U+RDJ0Bkrfd7AT2D7DkLLoIevLkd+MJ76Fj7VJO
 ifNxLd8TuLl8xZVu2GJNKIqWQ5ZXC1f2HD3IWbrMenBD9z1AKp9H2yudk4b6OP5obqYJAPNLL
 3CsFvBWxmq2DSrwrB+49Gk=

On 11.06.21 20:14, Eric W. Biederman wrote:

Hi,

> I favor none of the virtual devices showing up in sysfs.  Maybe existing
> userspace needs the devices in sysfs, but if the solution is simply to
> skip sysfs for virtual devices that is much simpler.

Sorry for being a little bit confused, but by virtual devices you mean
things like pty's or all the other stuff we already see under
/sys/device/virtual ?

I'm yet unsure what the better way is. If we're just talking about pty's
specifically, I maybe could live with threating them like "special sort
of pipes", but I guess that would require some extra magic.

If I'm not mistaken, the whole sysfs stuff is automatically handled
device classes and bus'es - seems that tty's are also class devs.

How would you skip the virtual devices from sysfs ? Adding some filter
into sysfs that looks at the device class (or some flag within it) ?

--mtx

-- 
---
Hinweis: unverschlüsselte E-Mails können leicht abgehört und manipuliert
werden ! Für eine vertrauliche Kommunikation senden Sie bitte ihren
GPG/PGP-Schlüssel zu.
---
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
