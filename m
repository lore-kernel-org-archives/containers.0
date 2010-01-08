From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
Date: Fri, 08 Jan 2010 08:55:40 +0800
Message-ID: <4B46828C.5000703__1378.70934927395$1262912208$gmane$org@cn.fujitsu.com>
References: <cover.1262186097.git.kirill@shutemov.name>	
	<9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>	
	<6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com>
	<cc557aab1001070436w446ef85n55dd2af5e733f55e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cc557aab1001070436w446ef85n55dd2af5e733f55e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Kirill A. Shutemov wrote:
> On Thu, Jan 7, 2010 at 3:01 AM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> On Wed, Dec 30, 2009 at 7:57 AM, Kirill A. Shutemov
>> <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
>>> +
>>> +       if (!IS_ERR(efile))
>>> +               fput(efile);
>> While this is OK currently, it's a bit fragile. efile starts as NULL,
>> and IS_ERR(NULL) is false. So if we jump to fail: before trying to do
>> the eventfd_fget() then we'll try to fput(NULL), which will oops. This
>> works because we don't currently jump to fail: until after
>> eventfd_fget(), but someone could add an extra setup step between the
>> kzalloc() and the eventfd_fget() which could fail.
> 
> So we need to use IS_ERR_OR_NULL here instread of IS_ERR, don't we?
> 

Use multi labels is much better:

label4::
	fput(cfile);
label3:
	eventfd_ctx_put(event->eventfd);
label2:
	fput(efile);
label1:
	kfree(event);

compared to:

+fail:
+	if (!IS_ERR(cfile))
+		fput(cfile);
+
+	if (event && event->eventfd && !IS_ERR(event->eventfd))
+		eventfd_ctx_put(event->eventfd);
+
+	if (!IS_ERR(efile))
+		fput(efile);
+
+	kfree(event);
