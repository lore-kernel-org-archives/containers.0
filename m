From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v3.01)
Date: Fri, 06 Aug 2010 07:31:08 -0700
Message-ID: <8762znlsnn.fsf@caffeine.danplanet.com>
References: <1281031026-2357-1-git-send-email-danms@us.ibm.com>
	<1281031026-2357-3-git-send-email-danms@us.ibm.com>
	<20100805214842.GP2927@count0.beaverton.ibm.com>
	<4C5B3DF9.4000907@cs.columbia.edu>
	<20100805234902.GS2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100805234902.GS2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org> (Matt Helsley's
	message of "Thu\, 5 Aug 2010 16\:49\:02 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

MH> Perhaps instead of mimicking the kernel data structure in the
MH> checkpoint image and then restoring that kernel structure during
MH> restart we could create a set of semops to write in the checkpoint
MH> image and then perform them during restart. By effectively calling
MH> sys_semop during restart we would ensure that we're doing the
MH> proper security checks, make the checkpoint image more portable
MH> (since the semop interface can't change), and greatly reduce the
MH> probability that c/r of the semaphores and their undo lists will
MH> bitrot (IOW make maintenance easy for everyone).

I actually started thinking down that road at one point.  However, the
way you get something into the undo list is you take action on a
semaphore, specifying that it should be undone later.  Unless we add a
semop to allow you to arbitrarily adjust the undo list (bad idea,
IMHO), using the semop interface would require us to modify the actual
semaphore.  We could potentially try to replay the semops that led to
the semaphore's value at checkpoint, but that seems more likely to
break to me.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
