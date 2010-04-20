From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6][usercr]: Rename/reorg usercr code
Date: Tue, 20 Apr 2010 11:07:33 -0700
Message-ID: <20100420180733.GA13874@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414004927.GA13012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| 
| Change the prefix of the USERCR apis to 'cr_' and reorg the code to avoid
| duplication and reduce code size.
| 
| 	[PATCH 1/6] Change API prefix to cr_
| 	[PATCH 2/6] Remove flags parameter to cr_checkpoint()
| 	[PATCH 3/6] Minor reorg of restart.c
| 	[PATCH 4/6] Move checkpoint() into restart.c
| 	[PATCH 5/6] Rename restart.c to cr_checkpoint.c
| 	[PATCH 6/6] Rename common.h to cr_log.h
| 
| With this change, USERCR for now "exports" just the following two files:
| 
| 	cr_checkpoint.o
| 	cr_checkpoint.h
| 
| But this patchset does cause some churn, let me know if you think any of it
| is unnecessary/noise.  I have tested for now along with the patch that removes
| most exits() from cr_restart(). If the reorg makes sense, will run all tests
| once more and resubmit.

All tests in cr-tests pass with these two patchsets (on usercr ckpt-v20-dev
and linux ckpt-v21-rc2).

Pls let me know if there are comments about the patchsets.

Thanks,

Sukadev
