From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Thu, 12 Mar 2009 16:29:54 -0500
Message-ID: <20090312162954.4a4b8e00@thinkcentre.lan>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236880612-15316-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dan.

Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> (apologies if you see this multiple times...IBM mail server troubles)
> 
> This patch adds a "phase" of c/r that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the nsproxy of the
> first task and making sure that the tasks that follow get hooked back to
> share the same one on restart.  On restart, we also explicitly create new
> namespaces for any that we support at the first task.

I'd like there to be some discussion about this, because namespace
creation seems like a significant addition to the semantics of restart
as I understand it.  Is namespace creation during restart unavoidable,
or merely desirable?  Is there a case for requiring the user to provide
a suitable namespace environment before attempting restart?
