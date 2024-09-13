Received: from frasgout12.his.huawei.com (frasgout12.his.huawei.com [14.137.139.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C39EA14A4FB
	for <containers@lists.linux.dev>; Fri, 13 Sep 2024 10:39:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=14.137.139.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726223976; cv=none; b=qyh1yh5brOuboJBqR+jHjPWZLbcfA77icfuSIQtrLbEnGiEi0J+qfMUvJkN2lcptEea6xSYf1oDjqY3Eg1dywSvkFlxzH6R7szd6JuegOivlZ6KDEpQJIaXDIVYmAzhUEg/TQlQLv1DNsgg15WgLc1rGBtXsR+01oObqxuBPQJ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726223976; c=relaxed/simple;
	bh=FeAp3pV84CzFfdmT3VZoKVKNHsnGG3F/cAqPbXXePqc=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:Cc:From:
	 In-Reply-To:Content-Type; b=MsjeWF6o+p2kJGI2gTxt5SSAeX7CCA8KarhEvhimg9KiE3XYj94HHjCxThUDVo6WLXDh4LjCjtrw1WRUYpvBEUAVXLXPYcaM44T47ZtNnD3OoKqTZVOPI/WZojD5PXItMhhjwA5ggxkHHVPwoEJAM6s7aJv15vy43bo+DYg027s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=huaweicloud.com; spf=pass smtp.mailfrom=huaweicloud.com; arc=none smtp.client-ip=14.137.139.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=huaweicloud.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huaweicloud.com
Received: from mail.maildlp.com (unknown [172.18.186.51])
	by frasgout12.his.huawei.com (SkyGuard) with ESMTP id 4X4qsf2qVXz9v7JY
	for <containers@lists.linux.dev>; Fri, 13 Sep 2024 18:14:14 +0800 (CST)
Received: from mail02.huawei.com (unknown [7.182.16.27])
	by mail.maildlp.com (Postfix) with ESMTP id 360941400D2
	for <containers@lists.linux.dev>; Fri, 13 Sep 2024 18:39:29 +0800 (CST)
Received: from [10.221.99.168] (unknown [10.221.99.168])
	by APP2 (Coremail) with SMTP id GxC2BwBXBsdXFuRmKR7XAA--.10238S2;
	Fri, 13 Sep 2024 11:39:27 +0100 (CET)
Message-ID: <f5ce940c-eaef-49d9-8c16-a41324b1fb2e@huaweicloud.com>
Date: Fri, 13 Sep 2024 12:39:16 +0200
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: CFP for the containers and checkpoint-restore micro-conference at
 LPC 2024 mailing/containers
To: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>,
 containers@lists.linux.dev
References: <CA+enf=tZs+B0OscmvyurqXjLwvwjhV7rZQ9-Rfi16BqAwUN6Cg@mail.gmail.com>
Content-Language: en-GB
Cc: Roberto Sassu <roberto.sassu@huaweicloud.com>, zohar@linux.ibm.com,
 Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org,
 James.Bottomley@HansenPartnership.com, brauner@kernel.org
From: Enrico Bravi <enrico.bravi@huaweicloud.com>
In-Reply-To: <CA+enf=tZs+B0OscmvyurqXjLwvwjhV7rZQ9-Rfi16BqAwUN6Cg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:GxC2BwBXBsdXFuRmKR7XAA--.10238S2
X-Coremail-Antispam: 1UD129KBjvJXoW7WFW8uw48Zw43Jr1fJry7ZFb_yoW8Cr4UpF
	Wjk3WFkw1Utw1fAw4kuF18ArWYkrWfWrW5A3s8G34rAFs8WasF9rySyFWY9Fy5GrWkJw43
	XFWYv3Z8Xa4DZFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUymb4IE77IF4wAFF20E14v26r4j6ryUM7CY07I20VC2zVCF04k2
	6cxKx2IYs7xG6rWj6s0DM7CIcVAFz4kK6r1j6r18M28lY4IEw2IIxxk0rwA2F7IY1VAKz4
	vEj48ve4kI8wA2z4x0Y4vE2Ix0cI8IcVAFwI0_Jr0_JF4l84ACjcxK6xIIjxv20xvEc7Cj
	xVAFwI0_Jr0_Gr1l84ACjcxK6I8E87Iv67AKxVW8JVWxJwA2z4x0Y4vEx4A2jsIEc7CjxV
	AFwI0_Gr0_Gr1UM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40E
	x7xfMcIj6xIIjxv20xvE14v26r1j6r18McIj6I8E87Iv67AKxVWUJVW8JwAm72CE4IkC6x
	0Yz7v_Jr0_Gr1lF7xvr2IY64vIr41lc7CjxVAaw2AFwI0_JF0_Jw1l42xK82IYc2Ij64vI
	r41l4I8I3I0E4IkC6x0Yz7v_Jr0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8Gjc
	xK67AKxVWUGVWUWwC2zVAF1VAY17CE14v26r1q6r43MIIYrxkI7VAKI48JMIIF0xvE2Ix0
	cI8IcVAFwI0_Jr0_JF4lIxAIcVC0I7IYx2IY6xkF7I0E14v26r1j6r4UMIIF0xvE42xK8V
	AvwI8IcIk0rVWUJVWUCwCI42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E
	14v26r1j6r4UYxBIdaVFxhVjvjDU0xZFpf9x07UK2NtUUUUU=
X-CM-SenderInfo: 5hquxuvroe2ttyl6x35dzhxuhorxvhhfrp/

On 6/6/2024 11:11 PM, Stéphane Graber wrote:
> Hello,
> 
> We're going to have the usual containers and checkpoint/restore
> micro-conference at this year's edition of the Linux Plumbers
> Conference.
> This is going to be in Vienna, Austria between September 18th and 20th 2024.
> 
> Registration is open already and as a reminder, getting accepted as a
> presenter in a micro-conference does not provide you with a ticket.
> Everyone who plans on attending, whether in-person or remotely should
> register now (early bird price until August 2nd).
> Registration: https://lpc.events/event/18/page/226-attend
> 
> Back to our micro-conference, the CFP is now open and will be closing
> on July 15th!
> Topics of interest are anything that's related to containers,
> namespaces, cgroups, ... whether in kernel land or userspace as well
> as anything that's related to the ability to checkpoint and restore
> processes.
> 
> Full CFP: https://discuss.linuxcontainers.org/t/containers-and-checkpoint-restore-micro-conference-at-lpc-2024/20131
> Submission link: https://lpc.events/event/18/abstracts/

Hi Stéphane, all,

Roberto and I are also planning to go the LPC. In the last months we had some 
thoughts on the IMA namespace and, if possible, we would like to share them with 
you in a presentation.

Title: IMA Namespace Best for Container Integrity?

Abstract:

The IMA namespace has been proposed a while ago but, despite many attempts at 
addressing maintainers' concerns, it didn't get upstreamed yet. Our work tries 
to determine if the IMA namespace fulfils the integrity requirements we 
initially defined, and proposes a few suggestions on how to improve it.

Would it be possible to present it at the end of the main conference, as a BoF?

Thank you and see you in Vienna!

Best regards,

Enrico

