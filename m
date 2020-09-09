Return-Path: <SRS0=JB7L=CS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73AF5C10DAA
	for <containers@archiver.kernel.org>; Wed,  9 Sep 2020 10:12:02 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BFFD321D7A
	for <containers@archiver.kernel.org>; Wed,  9 Sep 2020 10:12:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFD321D7A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=enjellic.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 87DEF87051;
	Wed,  9 Sep 2020 10:12:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id T26gJTyH3S5O; Wed,  9 Sep 2020 10:11:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D170287011;
	Wed,  9 Sep 2020 10:11:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E6E63C0052;
	Wed,  9 Sep 2020 10:11:57 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5C394C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  9 Sep 2020 10:11:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 4ACAA8748A
 for <containers@lists.linux-foundation.org>;
 Wed,  9 Sep 2020 10:11:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 31crtm6OGS8y
 for <containers@lists.linux-foundation.org>;
 Wed,  9 Sep 2020 10:11:55 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wind.enjellic.com (wind.enjellic.com [76.10.64.91])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3C56087484
 for <containers@lists.linux-foundation.org>;
 Wed,  9 Sep 2020 10:11:55 +0000 (UTC)
Received: from wind.enjellic.com (localhost [127.0.0.1])
 by wind.enjellic.com (8.15.2/8.15.2) with ESMTP id 089ABMRJ016828;
 Wed, 9 Sep 2020 05:11:23 -0500
Received: (from greg@localhost)
 by wind.enjellic.com (8.15.2/8.15.2/Submit) id 089ABLvd016827;
 Wed, 9 Sep 2020 05:11:21 -0500
Date: Wed, 9 Sep 2020 05:11:21 -0500
From: "Dr. Greg" <greg@enjellic.com>
To: Luke Hinds <lhinds@redhat.com>
Subject: Re: [RFC PATCH 00/30] ima: Introduce IMA namespace
Message-ID: <20200909101120.GA16191@wind.enjellic.com>
References: <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <20200818164943.va3um7toztazcfud@wittgenstein>
 <d77a6cd783319702fddd06783cb84fdeb86210a6.camel@linux.ibm.com>
 <20200906171413.GA8305@wind.enjellic.com>
 <CAKrSGQR3Pw=Rad2RgUuCHqr0r2Nc6x2nLoo2cVAkD+_8Vbmd7A@mail.gmail.com>
Mime-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAKrSGQR3Pw=Rad2RgUuCHqr0r2Nc6x2nLoo2cVAkD+_8Vbmd7A@mail.gmail.com>
User-Agent: Mutt/1.4i
X-Greylist: Sender passed SPF test, not delayed by milter-greylist-4.2.3
 (wind.enjellic.com [127.0.0.1]); Wed, 09 Sep 2020 05:11:23 -0500 (CDT)
Cc: Mimi Zohar <zohar@linux.ibm.com>,
 Christian Brauner <christian.brauner@ubuntu.com>, mkayaalp@cs.binghamton.edu,
 sunyuqiong1988@gmail.com, krzysztof.struczynski@huawei.com,
 silviu.vlasceanu@huawei.com, nick.dusek@gmail.com, jannh@google.com,
 viro@zeniv.linux.org.uk, christian@brauner.io, dmitry.kasatkin@gmail.com,
 containers@lists.linux-foundation.org, roberto.sassu@huawei.com,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, luto@amacapital.net,
 linux-security-module@vger.kernel.org, ebiederm@xmission.com,
 linux-integrity@vger.kernel.org, torvalds@linux-foundation.org
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Reply-To: "Dr. Greg" <greg@enjellic.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Sep 07, 2020 at 12:50:07PM +0100, Luke Hinds wrote:

Good morning, I hope the week is going well for everyone.

> On Sun, Sep 6, 2020 at 6:15 PM Dr. Greg <greg@enjellic.com> wrote:
> > Just to be clear, we are not campaigning or advocating what we have
> > done but are simply providing background for discussion.  We haven't
> > campaigned this approach given how complex the kernel development has
> > become, particurlarly with respect to security infrastructure.
> >
> > Candidly, given the politics of security technology being viewed as
> > 'constraining' user rights, I think that a lot of forthcoming security
> > technology may end up being out of tree moving forward.

> I think it's prudent to look forward and plan diligently, but I would not
> want perfect to be the enemy of good.
>
> I approach this more from a user's perspective. We are using IMA in
> https://keylime.dev to measure a host and would like to measure
> within a container too. It's the most common request we hear from
> our users.
>
> Perhaps we all collaborate on a proposal extending Stefans work here:
> https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerations
>
> I have seen around 3-4 patches now get submitted, so work has been
> done before, and as above, users are present too. We could then have
> some consensus on how this should look and later patches might have
> more success at landing.
>
> Would anyone be interested in this and have recommendations on how
> we could approach this?

Obviously everyone is interested in sharpening their own knives so the
first challenge will be defining where this theme of measurement and
attestation needs to go.

Our focus in all of this is from a platform behavior modeling
perspective.  Our objective is to design platforms/containers that are
capable of self-disciplining themselves in the event that they exhibit
behavior inconsistent with the wishes of their designer.  Container
measurement trivially falls out of this model.

With respect to measurement namespaces, the first problem to be
addressed is what takes custody and responsibility for the measurement
events.  In classic IMA this is, of course, a TPM.  In our model we
use a Trusted Execution Environment (TEE) as this entity.

The TEE makes a decision as to whether or not the kernel should label
a context of execution as being a 'bad actor' if it indicates a desire
to exhibit a behavior inconsistent with a previously defined model.
As I noted previously we have an SGX based solution that provides this
infrastructure but have designed and are moving to a micro-controller
based alternative, given the fact that SGX is now moving to a 'cloud
only' solution.

One of the pain points in all of this appears to be whether or not a
measurement stream from a container should feed into the root
measurement of the platform or be fed into a measurement/monitoring
domain that can be attested against the root measurement of the
platform.  Based on our experiences the latter model is the only one
that is feasible or makes sense from an attestation perspective.

So it would seem that a generic approach to directing the target of
the measurement events would be the first objective.  If there is
interest we can make a copy of our patch available as it supports both
models.

> - Luke

Have a good day.

Dr. Greg

As always,
Dr. Greg Wettstein, Ph.D, Worker      Autonomously self-defensive
Enjellic Systems Development, LLC     IOT platforms and edge devices.
4206 N. 19th Ave.
Fargo, ND  58102
PH: 701-281-1686                      EMAIL: dg@enjellic.com
------------------------------------------------------------------------------
"I created a hack to make the division come out right ... I was
 relieved because I thought I was coding wrong.

 Did you?  It took a guy (Thomas Nicely) with a Ph.D. doing heavy
 research in computational number theory to find it, yet you found it
 while working on a game in QuickBasic?"
                                -- Slashdot
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
