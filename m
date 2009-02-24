From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] c/r: Add s390 support
Date: Tue, 24 Feb 2009 11:31:08 -0800
Message-ID: <87ocwrljib.fsf@caffeine.danplanet.com>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235500639-9597-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Dan Smith's
	message of "Tue, 24 Feb 2009 13:37:17 -0500")
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

DS> This set includes an updated version of the s390 patch as well as
DS> a new one that adds the common CR_COPY() macros suggested by Dave.

For the sake of comparison, the (trimmed) diffstat of the original
patch was:

 arch/s390/include/asm/checkpoint_hdr.h |   99 +++++++++++++++++++++++++++
 arch/s390/mm/checkpoint.c              |  106 +++++++++++++++++++++++++++++
 arch/s390/mm/restart.c                 |  117 ++++++++++++++++++++++++++++++++
 8 files changed, 341 insertions(+), 2 deletions(-)

and after the macros it was

 arch/s390/include/asm/checkpoint_hdr.h |   84 +++++++++++++++++++++++++
 arch/s390/mm/checkpoint.c              |  104 ++++++++++++++++++++++++++++++++
 arch/s390/mm/restart.c                 |   71 ++++++++++++++++++++++
 8 files changed, 278 insertions(+), 2 deletions(-)

That's a savings of ~60 lines in the affected bits.  Personally, I
think that it makes the save/load bits significantly easier to read as
well.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
