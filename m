From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Thu, 02 Apr 2009 11:06:04 -0700
Message-ID: <87skkr2ann.fsf@caffeine.danplanet.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
	<1238533107-11796-3-git-send-email-danms@us.ibm.com>
	<20090402175804.GC21178@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090402175804.GC21178-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu, 2 Apr 2009 12:58:04 -0500")
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

>> +	uts = cr_obj_add_ptr(ctx, nsp->uts_ns, &hh->uts_ref, CR_OBJ_UTSNS, 0);

SH> I would prefer this be called 'uts_was_new' or something, though.

Fair enough.  I was trying to avoid wrapping that line :)

SH> Should probably memset them to 0 first.  I realize it doesn't
SH> really seem like security-relevant information leakage, but
SH> sys_hostname() does it, so it seems like we ought to as well.

Okay.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
