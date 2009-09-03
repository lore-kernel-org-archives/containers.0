From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them (v2)
Date: Thu, 03 Sep 2009 07:03:08 -0700
Message-ID: <87eiqoyvkz.fsf@caffeine.danplanet.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
	<1251915760-20118-2-git-send-email-danms@us.ibm.com>
	<20090903054058.GA7189@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090903054058.GA7189-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu\, 3 Sep 2009 00\:40\:58 -0500")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> I'm sure I sound like an idiot, but... at restore, a socket will
SH> be created for sk now.  Is that a problem?  I don't see where
SH> sk_free() will cause that sock to be freed, and you are not
SH> attaching it do a file whose close would cause it to be
SH> released...

In the regular socket code, the reference that is taken during
allocation is assumed to be for the owning object (the file).  So,
they don't take another ref when they actually attach it to a file.

The objhash assumes that for all objects on restore, the allocation
routine for the object has already incremented the reference count for
it as the owner.  If you look at restore_obj() it drops the ref count
right after stuffing the object in the hash because the act of
insertion grabs a reference.  On checkpoint, this is the reference for
the hash.  On restore, it would be redundant because it is the first
owner (not a file, etc).

My code takes *another* reference when it attaches to a file, if
appropriate.  In the case of the adopted socket, only the objhash
holds a reference to it, so unless it was joined to a peer, it will be
freed when the objhash does its final obj_ref_drop() at tear-down
time.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
