From: william <william-FuVYq0B8HF8swF9hGuCkNA@public.gmane.org>
Subject: cgroups and limit firefox  processes cpu time
Date: Fri, 22 Jan 2010 06:34:35 +0100
Message-ID: <4B5938EB.3040809@cobradevil.org>
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

Hello list

I have a question about how i can limit the cpu for a firefox process on 
a terminal server.

We have 150 firefox processes running on a terminalserver but there are 
always people who take more cpu when they use flash or java.
Some firefox processes take sometimes about 50 percent cpu time.
Is there a way to give all firefox processes equal cpu shares so that 
other people who are using firefox for research have no issues (slow 
responding scrolling and menu)  because there are a few firefox 
processes eating all the cpu time?

I hope i made clear what i meant, this is new to me and i haven't found 
other people with examples doing the same.

e.g
1 core
firefox 1 80%
firefox 2 60%
firefox 3 10%

now what i want is that the firefox processes 1 and 2 get the cpu time 
they want but if firefox process 3 is going todo something then he gets 
the cpu time he want's because the first two are over there limit.

I will be happy to answer questions to make this more clear.

With kind regards

William
