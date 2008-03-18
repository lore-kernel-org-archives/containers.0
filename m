From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] cgroups: implement device whitelist (v4)
Date: Tue, 18 Mar 2008 15:17:53 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0803181517260.1898@us.intercode.com.au>
References: <20080317180722.GA17111@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080317180722.GA17111@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Stephen Smalley <sds@epoch.ncsc.mil>, Pavel Emelianov <xemul@openvz.org>, Greg KH <greg@kroah.com>, Casey Schaufler <casey@schaufler-ca.com>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On Mon, 17 Mar 2008, Serge E. Hallyn wrote:

> Implement a cgroup to track and enforce open and mknod restrictions on device
> files.  A device cgroup associates a device access whitelist with each
> cgroup.  A whitelist entry has 4 fields.  'type' is a (all), c (char), or
> b (block).  'all' means it applies to all types and all major and minor
> numbers.  Major and minor are either an integer or * for all.
> Access is a composition of r (read), w (write), and m (mknod).

Acked-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
