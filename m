From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: C/R support of UNIX sockets
Date: Mon,  3 Aug 2009 13:30:58 -0700
Message-ID: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

This is my latest series of patches supporting the goal of
checkpoint/restart of AF_UNIX sockets.  Changes are detailed
per-patch, but a brief description is:

  - Update the errno helper patch to compaire against MAX_ERRNO
  - Update read_string() patch to use new _ckpt_read_obj_type()
    behavior and avoid a memory copy
  - Update the sock_bind() patch to include similar wrappers for
    sock_getname() and sock_getpeer()
  - Add a patch to export ckpt_fill_fname()
  - Update the AF_UNIX patch to integrate received feedback

Can some or all of these patches be included in the tree at this
point?  I think that some of the helper items should be ready for
that, and pulling in the UNIX patch will help make further
changes more clear instead of me just posting the large patch
each time.  Thoughts?
