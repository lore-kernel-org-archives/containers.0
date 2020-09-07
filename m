Return-Path: <SRS0=rxys=CQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5991C433E2
	for <containers@archiver.kernel.org>; Mon,  7 Sep 2020 11:50:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 30DF2207C3
	for <containers@archiver.kernel.org>; Mon,  7 Sep 2020 11:50:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gy30eMdn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30DF2207C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id BA4138667C;
	Mon,  7 Sep 2020 11:50:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ESSflUlGa+vl; Mon,  7 Sep 2020 11:50:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 09A7B86064;
	Mon,  7 Sep 2020 11:50:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DC7A6C0859;
	Mon,  7 Sep 2020 11:50:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1F69EC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  7 Sep 2020 11:50:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 0A1D7852F6
 for <containers@lists.linux-foundation.org>;
 Mon,  7 Sep 2020 11:50:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id W-9TeVlNANuQ
 for <containers@lists.linux-foundation.org>;
 Mon,  7 Sep 2020 11:50:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id F0E7085218
 for <containers@lists.linux-foundation.org>;
 Mon,  7 Sep 2020 11:50:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1599479432;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=LSM41Fl9TBq9xfemSclN8fs7sHcegx5R8CiOrNbnJPQ=;
 b=gy30eMdnt5ssMRXS/4gXEzavqynU94iKZxozNlH74nrnfrrHo3yk+2l3WVYqaYBayQbMsn
 wI+5wiTktlw0SUUNO5t7QDRlFCl9fwg+1VuLL9ZanQbef5WSoimb2c0wK7WMtAkgplU1Jz
 ywIzNrz1yXsIeHDXkNJZdzzPiuIe4/I=
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com
 [209.85.215.197]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-78-mARdD8ULPkmfkcS7PKpYsQ-1; Mon, 07 Sep 2020 07:50:21 -0400
X-MC-Unique: mARdD8ULPkmfkcS7PKpYsQ-1
Received: by mail-pg1-f197.google.com with SMTP id r22so5007033pgk.14
 for <containers@lists.linux-foundation.org>;
 Mon, 07 Sep 2020 04:50:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=LSM41Fl9TBq9xfemSclN8fs7sHcegx5R8CiOrNbnJPQ=;
 b=DlS8ltzkNlu0w3i2HwUXVqfC1cEI6dicI12uJ1ueosPLTWWCj3/5xfQRCnNbcAQK6M
 9JbYmTstC+JmxWJjYGYzg6ruWNXf8sV1lKUiNgZstCNwP5W20NwSboBVGN/gRyj2Mm9M
 dQGUPjSiAKny32xBA3pfAqEAF0d2hSvkjhIIK2yRHfJgf8IEXROhUKY5oPooDsOvq4jv
 q0jN/MJEPDKi4Ut0hsUn5dMrEbItX74YyamH8fu5HLMEeS1I4/0tayFhJTm4+/XyIEyv
 mmB13znweBCyjD51MBw60DsjadyJ4GFVhokLfHq7qILKdNYAmgdeXOi0sI9LFzEj2zUi
 Skdg==
X-Gm-Message-State: AOAM532/qUC9CHX90BXeAZzsxCxhMNvvzBVPas2ELNTkMGPfjTL159En
 azS8d/L2qb/KGCmZ46o8MHirUXRPxK8q37KrRXrBz+rgloEjGvc8nfrUM2VFKHTmGGUupHl/gUC
 ap881CMtIaOeUKO1HWjynLxehGzvEPfSInNDA/jSfIKDfK2Qu3nw=
X-Received: by 2002:a17:90a:7bcf:: with SMTP id
 d15mr8465830pjl.230.1599479418604; 
 Mon, 07 Sep 2020 04:50:18 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJzDsqoH0ihimlcDBcmMv979cpWBHIe1zn1i8IcGodsx7w5NP6LJzgwGdmXgbRKmbdhToikL2TbpBhdOVkKPOWw=
X-Received: by 2002:a17:90a:7bcf:: with SMTP id
 d15mr8465794pjl.230.1599479418219; 
 Mon, 07 Sep 2020 04:50:18 -0700 (PDT)
MIME-Version: 1.0
References: <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <20200818164943.va3um7toztazcfud@wittgenstein>
 <d77a6cd783319702fddd06783cb84fdeb86210a6.camel@linux.ibm.com>
 <20200906171413.GA8305@wind.enjellic.com>
In-Reply-To: <20200906171413.GA8305@wind.enjellic.com>
From: Luke Hinds <lhinds@redhat.com>
Date: Mon, 7 Sep 2020 12:50:07 +0100
Message-ID: <CAKrSGQR3Pw=Rad2RgUuCHqr0r2Nc6x2nLoo2cVAkD+_8Vbmd7A@mail.gmail.com>
Subject: Re: [RFC PATCH 00/30] ima: Introduce IMA namespace
To: "Dr. Greg" <greg@enjellic.com>
Authentication-Results: relay.mimecast.com;
 auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=lhinds@redhat.com
X-Mimecast-Spam-Score: 0.002
X-Mimecast-Originator: redhat.com
X-Content-Filtered-By: Mailman/MimeDel 2.1.15
Cc: Mimi Zohar <zohar@linux.ibm.com>,
 Christian Brauner <christian.brauner@ubuntu.com>, mkayaalp@cs.binghamton.edu,
 sunyuqiong1988@gmail.com, krzysztof.struczynski@huawei.com,
 silviu.vlasceanu@huawei.com, nick.dusek@gmail.com, jannh@google.com,
 viro@zeniv.linux.org.uk, dmitry.kasatkin@gmail.com,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Sun, Sep 6, 2020 at 6:15 PM Dr. Greg <greg@enjellic.com> wrote:

> On Wed, Sep 02, 2020 at 03:54:58PM -0400, Mimi Zohar wrote:
>
> Good morning, I hope the weekend is going well for everyone.
>
> A follow on to my previous e-mail regarding what 'namespaced IMA'
> should look like.
>
> > On Tue, 2020-08-18 at 18:49 +0200, Christian Brauner wrote:
> > > On Tue, Aug 18, 2020 at 05:20:07PM +0200,
> krzysztof.struczynski@huawei.com wrote:
> > > > From: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>
> > > > IMA has not been designed to work with containers. It handles
> > > > every process in the same way, and it cannot distinguish if a
> > > > process belongs to a container or not.
> > > >
> > > > Containers use namespaces to make it appear to the processes in
> > > > the containers that they have their own isolated instance of the
> > > > global resource. For IMA as well, it is desirable to let
> > > > processes in the
>
> > > IMA is brought up on a regular basis with "we want to have this" for
> > > years and then non-one seems to really care enough.
>
> I don't think it is a matter of lack of interest or not caring.  The
> challenge becomes whether or not a business case exists for expending
> the resources and navigating the challenges needed to advance
> infrastructure for inclusion in the kernel.
>
> > There is a lot of interest in IMA namespacing, but the question
> > always comes back to how to enable it.  Refer to
> > https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerations
> > for Stefan's analysis.
>
> As I noted in my previous e-mail, I believe the path forward is not to
> figure out how to address the rather complex and invasive issue of how
> to namespace IMA, but instead, needs to be what a flexible
> 'next-generation' architecture for platform behavioral assessment
> looks like.
>
> In a larger context, I believe the future for security is going to
> involve at a minimum the kernel, and more likely, something tightly
> coupled to the kernel, making active decisions on whether or not a
> behavior that the kernel is contemplating mediating is consistent with
> platform or container security policy.
>
> To frame this a bit, the well understood role of the kernel with
> respect to security is to mediate 'Turing Events', or Actor/Subject
> (A/S) interactions.  Both DAC and MAC are based on this concept with
> the interface between an Actor and Subject being a security 'gate'.
>
> Given this model, the most simplistic and direct path forward is to
> provide a namespace capable method of exporting a description of the
> identity parameters that characterize the entities involved in an A/S
> interaction.  The kernel, or as I previously suggested as more likely
> moving forward, a closely linked entity can then make a decision as to
> whether or not the behavior should be allowed.
>
> FWIW, as an example of the minimal impact of this method, here is the
> diffstat of such an implementation:
>
> ---------------------------------------------------------------------------
>  arch/x86/entry/syscalls/syscall_32.tbl    |    2 +
>  arch/x86/entry/syscalls/syscall_64.tbl    |    2 +
>  fs/proc/array.c                           |    7 +
>  fs/proc/namespaces.c                      |    4 +
>  include/linux/ima.h                       |   27 +
>  include/linux/nsproxy.h                   |    2 +
>  include/linux/proc_ns.h                   |    2 +
>  include/linux/sched.h                     |    3 +
>  include/linux/syscalls.h                  |    6 +
>  include/uapi/asm-generic/unistd.h         |    7 +-
>  include/uapi/linux/sched.h                |    1 +
>  kernel/fork.c                             |    5 +-
>  kernel/nsproxy.c                          |   18 +-
>  kernel/sys_ni.c                           |    4 +
>  security/Kconfig                          |    1 +
>  security/Makefile                         |    2 +
>  Security/ai/Kconfig                       |   12 +
>  security/ai/Makefile                      |    3 +
>  security/ai/ai.c                          |  137 ++
>  security/integrity/iint.c                 |    5 +
>  security/integrity/ima/Makefile           |    2 +-
>  security/integrity/ima/ima.h              |   17 +
>  security/integrity/ima/ima_api.c          |   37 +-
>  security/integrity/ima/ima_fs.c           |   10 +
>  security/integrity/ima/ima_identity.c     | 2204
> +++++++++++++++++++++++++++++
>  security/integrity/ima/ima_init.c         |    6 +-
>  security/integrity/ima/ima_main.c         |    7 +
>  security/integrity/ima/ima_policy.c       |   74 +-
>  security/integrity/ima/ima_queue.c        |   10 +-
>  security/integrity/ima/ima_template.c     |    6 +
>  security/integrity/ima/ima_template_lib.c |   71 +
>  security/integrity/ima/ima_template_lib.h |   10 +
>  security/integrity/integrity.h            |    4 +-
>  security/security.c                       |    1 +
>  34 files changed, 2684 insertions(+), 25 deletions(-)
> ---------------------------------------------------------------------------
>
> As can be seen, this was built out in the context of the IMA
> sub-system with the majority of the changes being encapsulated in one
> file.  This includes all of the infrastructure needed for a Trusted
> Execution Environment (TEE) to enforce kernel security policy
> decisions.
>
> In addition to a container specific representation of the current
> behavioral state, each namespace exports via a sysfs pseudo-file, the
> following behavioral definition for each A/S interaction.
>
> exchange pid{1} event{cboot:/home/greg/runc} actor{uid=0, euid=0, suid=0,
> gid=0, egid=0, sgid=0, fsuid=0, fsgid=0, cap=0x3fffffffff} subject{uid=50,
> gid=50, mode=0100755, name_length=15,
> name=f0da604ff3f0a3e16163bc9d2f99bb9bcd70397d211b746d0104299972cc5505,
> s_id=sda1, s_uuid=1bfef8aaa45f4bcaa846640ae4547ddc,
> digest=791a7cf8dec2afe302836b974b3c0f7b0a5983f76d857aa97658ce09d54f60f8}
>
> Which provides the framework for implementing any number of policy
> decisions, of which integrity is only one element.
>
> We had initially used SGX to implement a TEE based enforcement engine,
> but given the direction of hardware support, we have largely shelved
> our SGX development efforts in favor of using a micro-controller based
> approach.
>
> Given what appears to be the direction for mobile devices, a
> collection of specialized harware linked by an OS, the notion of a
> separate entity making security policy decisions seems relevant.
>
> > I understand "containers" is not a kernel construct, but from my very
> > limited perspective, IMA namespacing only makes sense in the context of
> > a "container".  The container owner may want to know which files have
> > been accessed/executed (measurements, remote attestation) and/or
> > constrain which files may be accessed/executed based on signatures
> > (appraisal).
>
> Trying to implement supportable and field maintainable 'trusted
> computing' is a fools errand without the notion of containerization of
> platform behavior.  This is true whether the target is the cloud or
> endpoint/IOT class devices.
>
> It seems well understood, that while containers are not a first class
> kernel entity, the kernel takes responsibility for implementing
> compartmentalization of resources.  It would seem that security event
> characterizations are consistent with that model.
>
> In addition, none of this works without developer support.  Framing
> behavior assessment in the form of containers means that behavioral
> trajectory definitions for the containers can be a byproduct of
> standard DEVOP's pipelines.
>
> > > I'm highly skeptical of the value of ~2500 lines of code even if
> > > it includes a bunch of namespace boilerplate. It's yet another
> > > namespace, and yet another security framework.  Why does IMA need
> > > to be a separate namespace? Keyrings are tied to user namespaces
> > > why can't IMA be?
>
> > In the context of a container, the measurement list and IMA/EVM
> > keyrings need to be setup before the first file is measured,
> > signature verified, or file hash included in the audit log.
>
> As I've noted previously, namespacing IMA is problematic, what is
> needed is something far simpler and more flexible that provides a
> framework for implementing policy outside of the kernel, or if in the
> kernel, in a highly customizable fashion.
>
> I think that it would be found that user namespaces bring too much
> baggage to the table.  The most effective path forward in this venue
> would seem to be to bring forward the most simplistic, flexiable and
> uncomplicated mechanism possible.
>
> In this model, classic IMA would serve as a trust root on whose
> shoulders a security orchestration framework stands.
>
> > > I believe Eric has even pointed that out before.
> > >
> > > Eric, thoughts?
>
> > Any help with the above scenario would very be much appreciated.
>
> Hopefully the conversation will benefit from actual field experience
> with doing this sort of thing in a supportable fashion.
>
> The concept of 'trusted computing' has been around since the days when
> Dave Grawrock designed TXT, which is heavily linked to the heritage of
> IMA.  The fact that effective solutions in widespread practice have
> not emerged, in the face of demonstrated need, suggests the need to
> develop new solution strategies.
>
> Just to be clear, we are not campaigning or advocating what we have
> done but are simply providing background for discussion.  We haven't
> campaigned this approach given how complex the kernel development has
> become, particurlarly with respect to security infrastructure.
>
> Candidly, given the politics of security technology being viewed as
> 'constraining' user rights, I think that a lot of forthcoming security
> technology may end up being out of tree moving forward.
>
>
I think it's prudent to look forward and plan diligently, but I would not
want perfect to be the enemy of good.

I approach this more from a user's perspective. We are using IMA in
https://keylime.dev to measure a host and would like to measure within a
container too. It's the most common request we hear from our users.

Perhaps we all collaborate on a proposal extending Stefans work here:
https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerations

I have seen around 3-4 patches now get submitted, so work has been done
before, and as above, users are present too. We could then have some
consensus on how this should look and later patches might have more success
at landing.

Would anyone be interested in this and have recommendations on how we could
approach this?

- Luke


> Mimi
>
> Best wishes for a productive week to everyone.
>
> Dr. Greg
>
> As always,
> Dr. Greg Wettstein, Ph.D, Worker      Autonomously self-defensive
> Enjellic Systems Development, LLC     IOT platforms and edge devices.
> 4206 N. 19th Ave.
> Fargo, ND  58102
> PH: 701-281-1686                      EMAIL: dg@enjellic.com
>
> ------------------------------------------------------------------------------
> "A large number of the world's technical challenges have been solved.
>  The far greater challenge lies in conveying an understanding of this
>  to the world."
>                                 -- Dr. Greg Wettstein
>                                    Resurrection
>
>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
