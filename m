From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH] namespaces: introduce sys_hijack (v4)
Date: Tue, 16 Oct 2007 23:28:22 +0200
Message-ID: <47152CF6.7000605@fr.ibm.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>	<6599ad830710160209w64765f2ao6a1f811b4ea50708@mail.gmail.com>	<20071016143744.GC30799@sergelap.austin.ibm.com>	<6599ad830710160932t3769bc29w8a6461274226633d@mail.gmail.com>	<20071016185737.GA4115@sergelap.austin.ibm.com>	<6599ad830710161203h50198ae5o73bfacad32dd8bb6@mail.gmail.com>
	<20071016191200.GB4115@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071016191200.GB4115-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


> asmlinkage long sys_hijack(unsigned long clone_flags, int which,
> 			   unsigned long id);

I expect to get more explanation of the arguments in the patch 
you are going to send :)

'which' is used as a switch for 'id' : pid or fd on a open cgroup 
directory. right ? 

Thanks,

C. 
