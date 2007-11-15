From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] namespaces: document unshare security implications
Date: Thu, 15 Nov 2007 11:01:17 -0600
Message-ID: <20071115170117.GA24529@sergelap.austin.ibm.com>
References: <20071109222145.GA30476@sergelap.austin.ibm.com>
	<m1ir43y5na.fsf@ebiederm.dsl.xmission.com>
	<20071115164035.GA23349@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071115164035.GA23349-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> > "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> > So I think CAP_SYS_ADMIN is a good starting place.  It is trivial verifiable
> > that it is safe.  So starting there allows us to work on other aspects
> > of the problem for now.
> 
> It was a good starting place, but at this point I have two concerns with
> sticking with CAP_SYS_ADMIN:
> 
> 	1. now that file capabilities are upstream, people may want to
> 	add just the requisite capability in fP for an unsharing helper
> 	program.  Cedric had mentioned wanting to do that.
> 	If we are going to switch to unprivileged unshares, then doing
> 	so later is ok.  But if we're going to switch to a custom
> 	capability later, then that could be seen as an API change
> 	since users will have to switch the capability on all the
> 	unsharing programs.
> 
> 	2. As I pointed out a few times, we can cleanly separate
> 	unsharing namespace and actually manipulating the resources.
> 	By requiring CAP_SYS_ADMIN for both unsharing a mounts namespace
> 	and for performing privileged mounts, any program given the
> 	authority to unshare is automatically given the authority to
> 	also completely manipulate the mounts, both in the new private
> 	namespace and the original namespace (by just not unsharing).
> 
> 	It's even worse with the net namespace, since the privilege
> 	needed to unshare the namespace authorizes you to update
> 	*other* namespaces in the system, but *not* network devices!
> 	But like you say let's stick with established namespaces.

Ok I'm being inconsistent (waffling between talking about not needing
capabilities and using a separate capability), imprecise, and overly
verbose.

Point 2 above is my key motivating factor.

So to attempt to state a clear, precise goal:

	If limited unprivileged updates to a namespace are possible,
	then the privilege needed to unshare the namespace should
	be as isolated from other privileges as possible.
	If limited unprivileged updates are not possible, or if
	unsharing implicitly equals updating (*1) then the
	privilege needed to unshare should equal that to update
	the namespace, not another namespace (*2).
	
*1: as may be the case with NETNS since the new network namespace
    is created empty
*2: i.e. not CAP_SYS_ADMIN to unshare(NETNS) and CAP_NET_ADMIN to update.

-serge
