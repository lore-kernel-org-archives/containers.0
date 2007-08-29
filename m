From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] [PATCH 0/2] namespace enter through hijack
Date: Wed, 29 Aug 2007 15:04:20 -0500
Message-ID: <20070829200420.GA4870@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset implements namespace entering by forcing a task in
the target namespace to clone itself.  This has some advantages
over just replacing a random task's namespace pointers to the
target ones.  In particular

	1. If switching pid namespaces, the stack of upids is
	   automatically correctly generated.
	2. Security context is inherited from the target
	   task.  Assuming a security module which labels
	   data based on the task security context, like selinux,
	   this may prevent severe mislabeling of container data by
	   an inadvertant host system administrator action.
	   Whether that works or not will still depend on the
	   policy and the task cloned.

While this version takes a pid of a process to clone (for
convenience of prototyping) we may prefer to use a ns_container
name and choose one of it's tasks, to prevent pid wraparound.

Tested and 'works for me', but at the moment I'm just sending
this out for discussion.

Alternatives to this include bind_ns()+switch_ns() by Cedric
and the ns_container namespace entering enhancements I've
previously sent.

thanks,
-serge
