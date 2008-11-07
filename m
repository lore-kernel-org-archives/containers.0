From: "Dong-Jae Kang" <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [Question] I have questions about dm-ioband
Date: Fri, 7 Nov 2008 14:39:56 +0900
Message-ID: <2891419e0811062139n5c0382a9n7d4fe7048d72dbf2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo tsuruta

During past several days, I had been analyzing and testing your
dm-ioband I/O controller.
because I received some requirements about disk I/O control from other
persons as below
"guaranteeing the minimum BW of processes in the specific group", of
course, in the total BW range.
I think it can be adjusted to streaming service, SLA of service
hosting part and so on.
although the applicable area is some specific and limited part, it can
be useful according to the service
How do you think about upper requirement?

If it is required, I think that try to support the function in your
dm-ioband controller
personally, I like your design and implementation style.
And, for it , where is the appropriate part in dm-ioband controller to
implement the function?
Can you give me some advice and comments about supporting it ?

I don't know well about the details of dm-ioband controllers, concept,
design, architecture and so on.
it will take some time for me to do that ^^
Well, Is there any documentations to help for me to understand the
existing implementation ?
If so, can I refer it ?

additional one question is left^^
dm-ioband can be operated with another dm targets at the same thme?
with such like multipath, mirror, linear, snapshot and something like that.
for example, IO control over the mirror targets or IO control over the
devices with multipath, ....

Oh,
Ryo tsuruta, sorry for many questions.

Thank you
-- 
Best Regards,
Dong-Jae Kang
