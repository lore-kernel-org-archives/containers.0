From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 08:55:22 -0700
Message-ID: <874oxq6d1x.fsf@caffeine.danplanet.com>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<20090312224820.GA12723@hallyn.com>
	<87bps6pcyf.fsf@caffeine.danplanet.com>
	<49C0B069.6060300@cs.columbia.edu> <20090318134932.GC22636@us.ibm.com>
	<878wn353mf.fsf@caffeine.danplanet.com> <49C1175F.9060600@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C1175F.9060600-GANU6spQydw@public.gmane.org> (Cedric Le Goater's message of "Wed,
	18 Mar 2009 16:46:39 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

CG> as you can't unshare(CLONE_NEWPID), you might consider doing a 

CG> 	clone(CLONE_NEW*|CLONE_WHATEVER)

CG> to restart 1 and then restart the container process tree under it

Yep, that's how mktree behaves with my changes. :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
