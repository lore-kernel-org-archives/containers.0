From: "Daniel Hokka Zakrisson" <daniel@hozac.com>
Subject: Re: [PATCH 0/4] user namespaces: introduction
Date: Mon, 28 Jan 2008 20:24:24 +0100 (CET)
Message-ID: <34757.192.168.101.12.1201548264.squirrel@intranet>
References: <20080128190828.GA8909@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080128190828.GA8909@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Here is a small patchset I've been sitting on for awhile
> to make signaling mostly subject to user namespaces.  In
> particular,
>
> 	1. store user_namespace in user struct
> 	2. introduce CAP_NS_OVERRIDE
> 	3. require CAP_NS_OVERRIDE to signal another user namespace
>
> The first step should have been done all along.  Else wouldn't
> a hash collision on (ns1, uid) and (ns2, uid), however unlikely,
> give us wrong results at uid_hash_find()?

Unless I've completely misunderstood the code, each namespace has a
separate hash. Please correct me if I'm wrong.

> The main remaining signaling+userns issue is of course the
> siginfo.  Tacking a userns onto siginfo is a pain due to
> lifetime mgmt issues.  I haven't decided whether to just
> catch all the callers and fake uid=0 if user namespaces
> aren't the same, introduce some unique non-refcounted id to
> represent (user,user_ns), or find some other way to deal with
> it.
>
> thanks,
> -serge

-- 
Daniel Hokka Zakrisson
