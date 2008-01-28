From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 0/4] user namespaces: introduction
Date: Mon, 28 Jan 2008 13:08:28 -0600
Message-ID: <20080128190828.GA8909@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Here is a small patchset I've been sitting on for awhile
to make signaling mostly subject to user namespaces.  In
particular,

	1. store user_namespace in user struct
	2. introduce CAP_NS_OVERRIDE
	3. require CAP_NS_OVERRIDE to signal another user namespace

The first step should have been done all along.  Else wouldn't
a hash collision on (ns1, uid) and (ns2, uid), however unlikely,
give us wrong results at uid_hash_find()?

The main remaining signaling+userns issue is of course the
siginfo.  Tacking a userns onto siginfo is a pain due to
lifetime mgmt issues.  I haven't decided whether to just
catch all the callers and fake uid=0 if user namespaces
aren't the same, introduce some unique non-refcounted id to
represent (user,user_ns), or find some other way to deal with
it.

thanks,
-serge
