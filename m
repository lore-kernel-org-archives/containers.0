From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 05/14] userns: Convert hostfs to use kuid and kgid where
	appropriate
Date: Mon, 24 Sep 2012 09:55:34 -0500
Message-ID: <20120924145534.GA5193@sergelap>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-5-git-send-email-ebiederm@xmission.com>
	<505F864C.2000103@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <505F864C.2000103-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org):
> Am 21.09.2012 02:28, schrieb Eric W. Biederman:
> > From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > 
> > Cc: Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
> > Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
> > Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > ---
> 
> Looks sane to me.
> 
> Acked-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
> 
> BTW: How you do test your user namespace patches?

I've got a few specific tests of the new functionality in the usernstest.c
in the nsexec package at
https://launchpad.net/~serge-hallyn/+archive/userns-natty/+sourcepub/2530252/+listing-archive-extra .
Of course LTP already has a good set of test cases for the regular
functionality.

> Is there a generic way to compare/verify uids within a namespace vs. the initial namespace?

It's good to look at output of 'id' in the task versus 'ps' from the initial ns,
as well as create a file and look at the stat output from both namespaces.

-serge
