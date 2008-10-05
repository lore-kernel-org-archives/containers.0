From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] user namespaces: introduce user_struct->user_namespace
 relationship
Date: Mon, 6 Oct 2008 08:50:09 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0810060846020.30516@tundra.namei.org>
References: <20081004013644.GA24104@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756682AbYJEVvU@vger.kernel.org>
In-Reply-To: <20081004013644.GA24104@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Fri, 3 Oct 2008, Serge E. Hallyn wrote:

> Hi James,
> 
> here are 3 patches to fix up the user namespaces a bit in preparation
> for real userns work to begin.  Andrew had suggested that these be
> rebased on top of your -next tree because they will conflict with
> the credentials work.  But it looks like much of the credentials stuff
> isn't in your next branch.  If you'd prefer that I port these to
> creds-next, please let me know.  I'll have to do it eventually :)

creds-next is dead.

Code ready for the next merge window is in the 'next' branch, while the 
current creds code is in the 'creds-next-subsys' branch, which hasn't been 
picked up in linux-next yet because of LPC and sfr's vacation.

When do you expect these patches to be sent upstream?  Are they ready now 
as an incremental change for 2.6.27?


- James
-- 
James Morris
<jmorris@namei.org>
