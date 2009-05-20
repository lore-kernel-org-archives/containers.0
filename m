From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Wed, 20 May 2009 10:53:32 -0500
Message-ID: <20090520155332.GA28999@us.ibm.com>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014538.GD28312@us.ibm.com>
	<4A142350.1060308@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A142350.1060308-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> Serge -
> 
> The 'creator' makes the 'struct user' recursive because to save
> an object you need to first save its creator etc. However the
> implementation may not call checkpoint_obj() recursively, if
> the depth isn't bound a-priory. You probably need to convert
> checkpoint_write_user() to do an iterative (loop) implementation
> of the recursion...

It's not done recursively, though.  checkpoint_write_userns() will
only be called by checkpoint_write_user().   checkpoint_write_user()
will make sure there are only 5 levels deep of unwritten creator
user namespace (else bail), then start at the oldest creator, and
write it.  That checkpoint_write_user will cause a write of its
user_ns, then write the user, then return to the original
checkpoint_write_user() which will now write the next-oldest
user_struct

So the max recursion depth we get is:

	checkpoint_task_struct -> checkpoint_write_cred ->
	checkpoint_write_user -> checkpoint_write_user ->
	checkpoint_write_userns (END)

-serge
